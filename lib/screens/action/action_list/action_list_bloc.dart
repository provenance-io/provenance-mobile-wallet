import 'dart:async';
import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:convert/convert.dart' as convert;
import 'package:get_it/get_it.dart';
import 'package:provenance_dart/proto.dart' as p;
import 'package:provenance_dart/wallet.dart' as wallet;
import 'package:provenance_dart/wallet_connect.dart';
import 'package:provenance_wallet/clients/multi_sig_client/multi_sig_client.dart';
import 'package:provenance_wallet/screens/action/action_list/action_list_error.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/account_service/default_transaction_handler.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/services/multi_sig_service/mult_sig_service.dart';
import 'package:provenance_wallet/services/wallet_connect_queue_service/models/wallet_connect_queue_group.dart';
import 'package:provenance_wallet/services/wallet_connect_queue_service/wallet_connect_queue_service.dart';
import 'package:provenance_wallet/services/wallet_connect_service/models/send_action.dart';
import 'package:provenance_wallet/services/wallet_connect_service/models/session_action.dart';
import 'package:provenance_wallet/services/wallet_connect_service/models/sign_action.dart';
import 'package:provenance_wallet/services/wallet_connect_service/models/wallet_connect_action.dart';
import 'package:provenance_wallet/services/wallet_connect_service/models/wallet_connect_action_kind.dart';
import 'package:provenance_wallet/services/wallet_connect_service/wallet_connect_service.dart';
import 'package:provenance_wallet/util/address_util.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/logs/logging.dart';
import 'package:provenance_wallet/util/strings.dart';

abstract class ActionListNavigator {
  Future<bool> showApproveSession(SessionAction sessionRequestData);

  Future<bool> showApproveSign(SignAction signRequest, ClientMeta clientMeta);

  Future<bool> showApproveTransaction({
    required List<p.GeneratedMessage> messages,
    List<p.Coin>? fees,
    ClientMeta? clientMeta,
  });
}

class _WalletConnectActionGroup extends ActionListGroup {
  _WalletConnectActionGroup({
    required String accountId,
    required String label,
    required String subLabel,
    required List<ActionListItem> items,
    required bool isSelected,
    required bool isBasicAccount,
    required WalletConnectQueueGroup queueGroup,
  })  : _queueGroup = queueGroup,
        super(
            accountId: accountId,
            label: label,
            subLabel: subLabel,
            items: items,
            isSelected: isSelected,
            isBasicAccount: isBasicAccount);

  final WalletConnectQueueGroup _queueGroup;
}

class _WalletConnectActionItem extends ActionListItem {
  _WalletConnectActionItem({
    required LocalizedString label,
    required LocalizedString subLabel,
    required this.action,
  }) : super(label: label, subLabel: subLabel);

  final WalletConnectAction action;
}

class ActionListGroup {
  const ActionListGroup({
    required this.accountId,
    required this.label,
    required this.subLabel,
    required this.items,
    required this.isSelected,
    required this.isBasicAccount,
  });

  final String accountId;
  final String label;
  final String subLabel;
  final bool isSelected;
  final bool isBasicAccount;
  final List<ActionListItem> items;
}

class ActionListItem {
  const ActionListItem({
    required this.label,
    required this.subLabel,
  });

  final LocalizedString label;
  final LocalizedString subLabel;
}

class NotificationItem {
  const NotificationItem({
    required this.label,
    required this.created,
  });

  final String label;
  final DateTime created;
}

class ActionListBlocState {
  ActionListBlocState(this.actionGroups, this.notificationGroups);

  List<ActionListGroup> actionGroups;
  List<NotificationItem> notificationGroups;
}

class ActionListBloc extends Disposable {
  final ActionListNavigator _navigator;
  final WalletConnectQueueService _connectQueueService;
  final AccountService _accountService;
  final MultiSigService _multiSigService;
  final MultiSigClient _multiSigClient;

  final _streamController = StreamController<ActionListBlocState>();

  ActionListBloc(this._navigator)
      : _connectQueueService = get<WalletConnectQueueService>(),
        _accountService = get<AccountService>(),
        _multiSigService = get<MultiSigService>(),
        _multiSigClient = get<MultiSigClient>();

  var notifications = [
    NotificationItem(
        label: "All co-signers have joined Space's Account",
        created: DateTime.now().subtract(Duration(hours: 1))),
    NotificationItem(
        label: "Invitation Declined",
        created: DateTime.now().subtract(Duration(days: 1))),
  ];

  Stream<ActionListBlocState> get stream => _streamController.stream;

  Future<void> init() async {
    _connectQueueService.addListener(_onActionQueueUpdated);
    _multiSigService.addListener(_onActionQueueUpdated);

    final accounts = (await _accountService.getAccounts())
        .whereType<TransactableAccount>()
        .toList();
    final addresses = accounts.map((e) => e.address).toList();
    await _multiSigService.sync(
      signerAddresses: addresses,
    );

    final actionGroups = await _buildActionGroups(accounts);
    final notifications = await _buildNotificationItems();

    _streamController.add(ActionListBlocState(actionGroups, notifications));
  }

  @override
  FutureOr onDispose() {
    _connectQueueService.removeListener(_onActionQueueUpdated);
    _multiSigService.removeListener(_onActionQueueUpdated);
    _streamController.close();
  }

  Future<void> deleteNotifications(List<NotificationItem> notifications) async {
    this.notifications = this.notifications.where((item) {
      return !notifications.contains(item);
    }).toList();

    Future.wait([_buildActionGroups(), _buildNotificationItems()])
        .then((results) {
      final actionGroups = results[0] as List<ActionListGroup>;
      final notifications = results[1] as List<NotificationItem>;

      _streamController.add(ActionListBlocState(actionGroups, notifications));
    });
  }

  Future<bool> requestApproval(
      ActionListGroup group, ActionListItem item) async {
    bool approved;

    if (group is _WalletConnectActionGroup) {
      approved = await _approveWalletConnectItem(
        group,
        item as _WalletConnectActionItem,
      );
    } else if (item is MultiSigSignActionListItem) {
      approved = await _navigator.showApproveTransaction(
        messages: item.txBody.messages.map((e) => e.toMessage()).toList(),
        fees: item.fee.amount,
      );
    } else if (item is MultiSigTransmitActionListItem) {
      approved = await _navigator.showApproveTransaction(
        messages: item.txBody.messages.map((e) => e.toMessage()).toList(),
        fees: item.fee.amount,
      );
    } else {
      log("Unknown actionType ${group.runtimeType}");
      approved = false;
    }

    return approved;
  }

  Future<void> processWalletConnectQueue(
      bool approved, ActionListGroup group, ActionListItem item) async {
    if (group is _WalletConnectActionGroup) {
      await _processWalletConnectItem(
        approved,
        group,
        item as _WalletConnectActionItem,
      );
    } else if (item is MultiSigSignActionListItem) {
      await _processMultiSigSignItem(approved, group, item);
    } else if (item is MultiSigTransmitActionListItem) {
      await _processMultiSigTransmitItem(approved, group, item);
    } else {
      log("Unknown actionType ${group.runtimeType}");
    }
  }

  void _onActionQueueUpdated() {
    Future.wait([_buildActionGroups(), _buildNotificationItems()])
        .then((results) {
      final actionGroups = results[0] as List<ActionListGroup>;
      final notifications = results[1] as List<NotificationItem>;

      _streamController.add(ActionListBlocState(actionGroups, notifications));
    });
  }

  Future<List<NotificationItem>> _buildNotificationItems() async {
    return notifications;
  }

  Future<List<ActionListGroup>> _buildActionGroups(
      [List<TransactableAccount>? txAccounts]) async {
    final currentAccount = _accountService.events.selected.value;
    final accounts = txAccounts ??
        (await _accountService.getAccounts())
            .whereType<TransactableAccount>()
            .toList();

    final accountLookup = accounts.asMap().map(
          (key, value) => MapEntry(
            value.address,
            value,
          ),
        );

    final groups = <ActionListGroup>[];

    final queuedItems = await _connectQueueService.loadAllGroups();

    final walletConnectGroups = queuedItems
        .where((queuedGroup) => queuedGroup.actionLookup.isNotEmpty)
        .map((queuedGroup) {
      final account = accountLookup[queuedGroup.accountAddress]!;

      return _WalletConnectActionGroup(
        accountId: account.id,
        queueGroup: queuedGroup,
        label: account.name,
        subLabel: abbreviateAddress(queuedGroup.accountAddress),
        isSelected: currentAccount!.id == account.id,
        isBasicAccount: account.kind == AccountKind.basic,
        items: queuedGroup.actionLookup.entries.map((entry) {
          LocalizedString label;
          if (entry.value is SessionAction) {
            label = (c) => Strings.of(c).actionListLabelApproveSession;
          } else if (entry.value is SignAction) {
            label = (c) => Strings.of(c).actionListLabelSignatureRequested;
          } else if (entry.value is SendAction) {
            label = (c) => Strings.of(c).actionListLabelTransactionRequested;
          } else {
            label = (c) => Strings.of(c).actionListLabelUnknown;
          }
          return _WalletConnectActionItem(
            label: label,
            subLabel: (c) => Strings.of(c).actionListSubLabelActionRequired,
            action: entry.value,
          );
        }).toList(),
      );
    });

    groups.addAll(walletConnectGroups);

    final multiSigItems = _multiSigService.items;

    final multiSigGroups = <String, List<MultiSigActionListItem>>{};
    for (final multiSigItem in multiSigItems) {
      final address = multiSigItem.signerAddress;

      if (!multiSigGroups.containsKey(address)) {
        multiSigGroups[address] = <MultiSigActionListItem>[];
      }

      multiSigGroups[address]!.add(multiSigItem);
    }

    for (final multiSigGroup in multiSigGroups.entries) {
      final account = accountLookup[multiSigGroup.key]!;
      final name = account.name;

      groups.add(
        ActionListGroup(
          accountId: account.id,
          label: name,
          subLabel: abbreviateAddress(multiSigGroup.key),
          items: multiSigGroup.value,
          isSelected: currentAccount!.id == account.id,
          isBasicAccount: false,
        ),
      );
    }

    return groups;
  }

  Future<bool> _approveWalletConnectItem(
      _WalletConnectActionGroup group, _WalletConnectActionItem item) {
    final payload = item.action;

    if (payload is SessionAction) {
      return _navigator.showApproveSession(payload as SessionAction);
    } else if (payload is SignAction) {
      return _navigator.showApproveSign(payload, group._queueGroup.clientMeta!);
    } else if (payload is SendAction) {
      return _navigator.showApproveTransaction(
        messages: payload.messages,
        fees: payload.gasEstimate.totalFees,
        clientMeta: group._queueGroup.clientMeta,
      );
    } else {
      throw Exception("Unknown action type ${item.runtimeType}");
    }
  }

  Future<void> _processWalletConnectItem(bool approved,
      _WalletConnectActionGroup group, _WalletConnectActionItem item) async {
    final walletConnectService = get<WalletConnectService>();

    final action = item.action;

    switch (action.kind) {
      case WalletConnectActionKind.session:
        await walletConnectService.approveSession(
          details: action as SessionAction,
          allowed: approved,
        );
        break;
      case WalletConnectActionKind.send:
      case WalletConnectActionKind.sign:
        await walletConnectService.sendMessageFinish(
          requestId: action.id,
          allowed: approved,
        );
        break;
    }
  }

  Future<void> _processMultiSigTransmitItem(bool approved,
      ActionListGroup group, MultiSigTransmitActionListItem item) async {
    if (!approved) {
      // TODO-Roy: Send update to service
      return;
    }

    final accountId = group.accountId;
    final accounts = await _accountService.getTransactableAccounts();
    final multiSigAccount = accounts
        .whereType<MultiTransactableAccount>()
        .firstWhereOrNull((e) => e.linkedAccount.address == item.signerAddress);
    if (multiSigAccount == null) {
      throw ActionListError.multiSigAccountNotFound;
    }

    final coin = getCoinFromAddress(item.multiSigAddress);
    final pbClient = await get<ProtobuffClientInjector>().call(coin);

    final authBytes = await _sign(
      pbClient: pbClient,
      multiSigAddress: item.multiSigAddress,
      signerAccountId: accountId,
      txBody: item.txBody,
      fee: item.fee,
    );

    final unorderedSignatures = {
      item.signerAddress: authBytes,
      ...item.signatures.asMap().map(
            (key, value) => MapEntry(
              value.signerAddress,
              convert.hex.decode(value.signatureHex),
            ),
          ),
    };

    // TODO-Roy: Provide order on sig model and order them here instead of
    // at point of storage for improved transparency.
    final sigLookup = <String, List<int>>{};
    for (final publicKey in multiSigAccount.publicKey.publicKeys) {
      final address = publicKey.address;
      final sig = unorderedSignatures[address];
      if (sig != null) {
        sigLookup[address] = sig;
      }
    }

    final privateKey = wallet.AminoPrivKey(
      threshold: multiSigAccount.signaturesRequired,
      pubKeys: multiSigAccount.publicKey.publicKeys,
      coin: coin,
      sigLookup: sigLookup,
    );

    final responsePair = await pbClient.broadcastTransaction(
      item.txBody,
      [
        privateKey,
      ],
      item.fee,
    );

    await _multiSigService.finalizeTx(
      signerAddress: item.signerAddress,
      txUuid: item.txUuid,
      response: responsePair.txResponse,
      coin: coin,
      fee: item.fee,
    );

    logDebug('Multi-sig tx response: ${responsePair.txResponse.rawLog}');
  }

  Future<void> _processMultiSigSignItem(bool approved, ActionListGroup group,
      MultiSigSignActionListItem item) async {
    if (!approved) {
      // TODO-Roy: Send update to service
      return;
    }

    final accountId = group.accountId;
    final coin = getCoinFromAddress(item.signerAddress);
    final pbClient = await get<ProtobuffClientInjector>().call(coin);

    final authBytes = await _sign(
      pbClient: pbClient,
      multiSigAddress: item.multiSigAddress,
      signerAccountId: accountId,
      txBody: item.txBody,
      fee: item.fee,
    );

    final signatureBytes = convert.hex.encode(authBytes);

    final success = await _multiSigClient.signTx(
      signerAddress: item.signerAddress,
      txUuid: item.txUuid,
      signatureBytes: signatureBytes,
    );

    if (success) {
      // Fetch all in case creator and co-signer are both in same app
      final addresses = (await _accountService.getAccounts())
          .whereType<TransactableAccount>()
          .map((e) => e.address)
          .toList();

      await _multiSigService.sync(
        signerAddresses: addresses,
      );
      _onActionQueueUpdated();
    }

    final status = success ? 'succeeded' : 'failed';

    logDebug('Sign tx ${item.txUuid} $status');

    if (!success) {
      throw ActionListError.multiSigSendSignatureFailed;
    }
  }

  Future<List<int>> _sign({
    required p.PbClient pbClient,
    required String multiSigAddress,
    required String signerAccountId,
    required p.TxBody txBody,
    required p.Fee fee,
  }) async {
    final signerRootPk = await _accountService.loadKey(signerAccountId);

    final signerPk = signerRootPk!.defaultKey();

    final multiSigBaseAccount = await pbClient.getBaseAccount(multiSigAddress);

    final authBytes = pbClient.generateMultiSigAuthorization(
      signerPk,
      txBody,
      fee,
      multiSigBaseAccount,
    );

    return authBytes;
  }
}

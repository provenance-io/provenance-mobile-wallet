import 'dart:async';
import 'dart:developer';

import 'package:get_it/get_it.dart';
import 'package:provenance_dart/proto.dart' as p;
import 'package:provenance_dart/wallet_connect.dart';
import 'package:provenance_wallet/clients/multi_sig_client/dto/multi_sig_status.dart';
import 'package:provenance_wallet/clients/multi_sig_client/models/multi_sig_pending_tx.dart';
import 'package:provenance_wallet/screens/action/action_list/action_list_error.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/services/multi_sig_service/multi_sig_service.dart';
import 'package:provenance_wallet/services/tx_queue_service/tx_queue_service.dart';
import 'package:provenance_wallet/services/wallet_connect_queue_service/models/wallet_connect_queue_group.dart';
import 'package:provenance_wallet/services/wallet_connect_queue_service/wallet_connect_queue_service.dart';
import 'package:provenance_wallet/services/wallet_connect_service/models/session_action.dart';
import 'package:provenance_wallet/services/wallet_connect_service/models/sign_action.dart';
import 'package:provenance_wallet/services/wallet_connect_service/models/tx_action.dart';
import 'package:provenance_wallet/services/wallet_connect_service/models/wallet_connect_action.dart';
import 'package:provenance_wallet/services/wallet_connect_service/models/wallet_connect_action_kind.dart';
import 'package:provenance_wallet/services/wallet_connect_service/wallet_connect_service.dart';
import 'package:provenance_wallet/util/address_util.dart';
import 'package:provenance_wallet/util/extensions/generated_message_extension.dart';
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

class ActionListBlocState {
  ActionListBlocState(this.actionGroups);

  List<ActionListGroup> actionGroups;
}

class ActionListBloc extends Disposable {
  final ActionListNavigator _navigator;
  final WalletConnectService _connectService;
  final WalletConnectQueueService _connectQueueService;
  final AccountService _accountService;
  final MultiSigService _multiSigService;
  final TxQueueService _txQueueService;

  final _streamController = StreamController<ActionListBlocState>();

  ActionListBloc(this._navigator)
      : _connectService = get<WalletConnectService>(),
        _connectQueueService = get<WalletConnectQueueService>(),
        _accountService = get<AccountService>(),
        _multiSigService = get<MultiSigService>(),
        _txQueueService = get<TxQueueService>();

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

    _streamController.add(ActionListBlocState(actionGroups));
  }

  @override
  FutureOr onDispose() {
    _connectQueueService.removeListener(_onActionQueueUpdated);
    _multiSigService.removeListener(_onActionQueueUpdated);
    _streamController.close();
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
      await _processMultiSigTransmitItem(approved, item);
    } else {
      log("Unknown actionType ${group.runtimeType}");
    }
  }

  Future<void> _onActionQueueUpdated() async {
    final groups = await _buildActionGroups();

    _streamController.add(
      ActionListBlocState(groups),
    );
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
          LocalizedString label = (c) => Strings.of(c).actionListLabelUnknown;

          switch (entry.value.kind) {
            case WalletConnectActionKind.session:
              label = (c) => Strings.of(c).actionListLabelApproveSession;
              break;
            case WalletConnectActionKind.tx:
              label = (c) => Strings.of(c).actionListLabelTransactionRequested;
              break;
            case WalletConnectActionKind.sign:
              label = (c) => Strings.of(c).actionListLabelSignatureRequested;
              break;
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

    final multiSigGroups = <String, List<MultiSigActionListItem>>{};

    final multiSigItems = _multiSigService.items;
    for (final item in multiSigItems.map(_toMultiSigListItem)) {
      final address = item.groupAddress;

      if (!multiSigGroups.containsKey(address)) {
        multiSigGroups[address] = <MultiSigActionListItem>[];
      }

      multiSigGroups[address]!.add(item);
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

  MultiSigActionListItem _toMultiSigListItem(MultiSigPendingTx tx) {
    switch (tx.status) {
      case MultiSigStatus.pending:
        return _toSignListItem(tx);
      case MultiSigStatus.ready:
        return _toTransmitListItem(tx);
      default:
        throw 'Invalid tx status: ${tx.status.name}';
    }
  }

  MultiSigTransmitActionListItem _toTransmitListItem(MultiSigPendingTx tx) =>
      MultiSigTransmitActionListItem(
        multiSigAddress: tx.multiSigAddress,
        signerAddress: tx.signerAddress,
        groupAddress: tx.multiSigAddress,
        label: (c) => tx.txBody.messages
            .map((e) => e.toMessage().toLocalizedName(c))
            .join(', '),
        subLabel: (c) => Strings.of(c).actionListSubLabelActionRequired,
        txBody: tx.txBody,
        fee: tx.fee,
        txId: tx.txUuid,
        signatures: tx.signatures!,
      );

  MultiSigSignActionListItem _toSignListItem(MultiSigPendingTx tx) =>
      MultiSigSignActionListItem(
        multiSigAddress: tx.multiSigAddress,
        signerAddress: tx.signerAddress,
        groupAddress: tx.signerAddress,
        label: (c) => tx.txBody.messages
            .map((e) => e.toMessage().toLocalizedName(c))
            .join(', '),
        subLabel: (c) => Strings.of(c).actionListSubLabelActionRequired,
        txBody: tx.txBody,
        fee: tx.fee,
        txId: tx.txUuid,
      );

  Future<bool> _approveWalletConnectItem(
      _WalletConnectActionGroup group, _WalletConnectActionItem item) {
    final action = item.action;

    switch (action.kind) {
      case WalletConnectActionKind.session:
        return _navigator.showApproveSession(action as SessionAction);
      case WalletConnectActionKind.tx:
        final txAction = action as TxAction;

        return _navigator.showApproveTransaction(
          messages: txAction.messages,
          fees: txAction.gasEstimate.totalFees,
          clientMeta: group._queueGroup.clientMeta,
        );
      case WalletConnectActionKind.sign:
        return _navigator.showApproveSign(
          action as SignAction,
          group._queueGroup.clientMeta!,
        );
    }
  }

  Future<void> _processWalletConnectItem(bool approved,
      _WalletConnectActionGroup group, _WalletConnectActionItem item) async {
    final action = item.action;

    switch (action.kind) {
      case WalletConnectActionKind.session:
        await _connectService.approveSession(
          details: action as SessionAction,
          allowed: approved,
        );
        break;
      case WalletConnectActionKind.tx:
      case WalletConnectActionKind.sign:
        await _connectService.sendMessageFinish(
          requestId: action.id,
          allowed: approved,
        );
        break;
    }
  }

  Future<void> _processMultiSigTransmitItem(
      bool approved, MultiSigTransmitActionListItem item) async {
    if (!approved) {
      // TODO-Roy: Send update to service
      return;
    }

    await _txQueueService.completeTx(txId: item.txId);
  }

  Future<void> _processMultiSigSignItem(bool approved, ActionListGroup group,
      MultiSigSignActionListItem item) async {
    if (!approved) {
      // TODO-Roy: Send update to service
      return;
    }

    final success = await _txQueueService.signTx(
      txId: item.txId,
      signerAddress: item.signerAddress,
      multiSigAddress: item.multiSigAddress,
      txBody: item.txBody,
      fee: item.fee,
    );

    // TODO-Roy: not needed, sync should pick up the change?
    // _onActionQueueUpdated();

    final status = success ? 'succeeded' : 'failed';

    logDebug('Sign tx ${item.txId} $status');

    if (!success) {
      throw ActionListError.multiSigSendSignatureFailed;
    }
  }
}

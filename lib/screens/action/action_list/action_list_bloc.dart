import 'dart:async';
import 'dart:developer';

import 'package:get_it/get_it.dart';
import 'package:provenance_dart/wallet_connect.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/services/models/requests/send_request.dart';
import 'package:provenance_wallet/services/models/requests/sign_request.dart';
import 'package:provenance_wallet/services/models/wallet_connect_session_request_data.dart';
import 'package:provenance_wallet/services/multi_sig_pending_tx_cache/mult_sig_pending_tx_cache.dart';
import 'package:provenance_wallet/services/wallet_connect_queue_service/wallet_connect_queue_service.dart';
import 'package:provenance_wallet/services/wallet_connect_service/wallet_connect_service.dart';
import 'package:provenance_wallet/util/address_util.dart';
import 'package:provenance_wallet/util/get.dart';

abstract class ActionListNavigator {
  Future<bool> showApproveSession(
      WalletConnectSessionRequestData sessionRequestData);

  Future<bool> showApproveSign(SignRequest signRequest, ClientMeta clientMeta);

  Future<bool> showApproveTransaction(
      SendRequest sendRequest, ClientMeta clientMeta);
}

class _WalletConnectActionGroup extends ActionListGroup {
  _WalletConnectActionGroup(
      {required String label,
      required String subLabel,
      required List<ActionListItem> items,
      required bool isSelected,
      required bool isBasicAccount,
      required WalletConnectQueueGroup queueGroup})
      : _queueGroup = queueGroup,
        super(
            label: label,
            subLabel: subLabel,
            items: items,
            isSelected: isSelected,
            isBasicAccount: isBasicAccount);

  final WalletConnectQueueGroup _queueGroup;
}

class _WalletConnectActionItem extends ActionListItem {
  _WalletConnectActionItem(
      {required String label, required String subLabel, required this.payload})
      : super(label: label, subLabel: subLabel);

  final dynamic payload;
}

class ActionListGroup {
  const ActionListGroup({
    required this.label,
    required this.subLabel,
    required this.items,
    required this.isSelected,
    required this.isBasicAccount,
  });

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

  final String label;
  final String subLabel;
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
  final MultiSigPendingTxCache _multiSigPendingTxCache;
  final String approveSessionLabel;
  final String signatureRequestedLabel;
  final String transactionRequestedLabel;
  final String unknownLabel;
  final String actionRequiredSubLabel;

  final _streamController = StreamController<ActionListBlocState>();

  ActionListBloc(
    this._navigator, {
    required this.approveSessionLabel,
    required this.signatureRequestedLabel,
    required this.transactionRequestedLabel,
    required this.unknownLabel,
    required this.actionRequiredSubLabel,
  })  : _connectQueueService = get<WalletConnectQueueService>(),
        _accountService = get<AccountService>(),
        _multiSigPendingTxCache = get<MultiSigPendingTxCache>();

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
    _multiSigPendingTxCache.addListener(_onActionQueueUpdated);

    final accounts = (await _accountService.getAccounts())
        .whereType<TransactableAccount>()
        .toList();
    final addresses = accounts.map((e) => e.address).toList();
    await _multiSigPendingTxCache.update(
      signerAddresses: addresses,
    );

    final actionGroups = await _buildActionGroups(accounts);
    final notifications = await _buildNotificationItems();

    _streamController.add(ActionListBlocState(actionGroups, notifications));
  }

  @override
  FutureOr onDispose() {
    _connectQueueService.removeListener(_onActionQueueUpdated);
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
    if (group is! _WalletConnectActionGroup) {
      log("Unknown actionType ${group.runtimeType}");
      return false;
    }

    return _approveWalletConnectGroup(group, item as _WalletConnectActionItem);
  }

  Future<void> processWalletConnectQueue(
      bool approved, ActionListGroup group, ActionListItem item) async {
    if (group is! _WalletConnectActionGroup) {
      log("Unknown actionType ${group.runtimeType}");
      return;
    }

    return _processWalletConnectGroup(
        approved, group, item as _WalletConnectActionItem);
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
      final account = accountLookup[queuedGroup.walletAddress];
      return _WalletConnectActionGroup(
        queueGroup: queuedGroup,
        label: account!.name,
        subLabel: abbreviateAddress(queuedGroup.walletAddress),
        isSelected: currentAccount!.id == account.id,
        isBasicAccount: account.kind == AccountKind.basic,
        items: queuedGroup.actionLookup.entries.map((entry) {
          String label;
          if (entry.value is WalletConnectSessionRequestData) {
            label = approveSessionLabel;
          } else if (entry.value is SignRequest) {
            label = signatureRequestedLabel;
          } else if (entry.value is SendRequest) {
            label = transactionRequestedLabel;
          } else {
            label = unknownLabel;
          }
          return _WalletConnectActionItem(
            label: label,
            subLabel: actionRequiredSubLabel,
            payload: entry.value,
          );
        }).toList(),
      );
    });

    groups.addAll(walletConnectGroups);

    final multiSigItems = _multiSigPendingTxCache.items;

    final multiSigGroups = <String, List<MultiSigActionListItem>>{};
    for (final multiSigItem in multiSigItems) {
      final address = multiSigItem.address;

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

  Future<bool> _approveWalletConnectGroup(
      _WalletConnectActionGroup group, _WalletConnectActionItem item) {
    final payload = item.payload;

    if (payload is WalletConnectSessionRequestData) {
      return _navigator.showApproveSession(payload);
    } else if (payload is SignRequest) {
      return _navigator.showApproveSign(payload, group._queueGroup.clientMeta!);
    } else if (payload is SendRequest) {
      return _navigator.showApproveTransaction(
          payload, group._queueGroup.clientMeta!);
    } else {
      throw Exception("Unknown action type ${item.runtimeType}");
    }
  }

  Future<void> _processWalletConnectGroup(bool approved,
      _WalletConnectActionGroup group, _WalletConnectActionItem item) async {
    final walletConnectService = get<WalletConnectService>();

    final payload = item.payload;

    if (payload is WalletConnectSessionRequestData) {
      await walletConnectService.approveSession(
        details: payload,
        allowed: approved,
      );
    } else if (payload is SignRequest) {
      await walletConnectService.sendMessageFinish(
          requestId: payload.id, allowed: approved);
    } else if (payload is SendRequest) {
      await walletConnectService.sendMessageFinish(
          requestId: payload.id, allowed: approved);
    } else {
      throw Exception("Unknown action type ${item.runtimeType}");
    }
  }
}

import 'dart:async';
import 'dart:developer';

import 'package:get_it/get_it.dart';
import 'package:provenance_dart/wallet_connect.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/services/models/requests/send_request.dart';
import 'package:provenance_wallet/services/models/requests/sign_request.dart';
import 'package:provenance_wallet/services/models/wallet_connect_session_request_data.dart';
import 'package:provenance_wallet/services/wallet_connect_queue_service/wallet_connect_queue_service.dart';
import 'package:provenance_wallet/services/wallet_connect_service/wallet_connect_service.dart';
import 'package:provenance_wallet/util/address_util.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

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

  final _streamController = StreamController<ActionListBlocState>();

  ActionListBloc(this._navigator)
      : _connectQueueService = get<WalletConnectQueueService>(),
        _accountService = get<AccountService>();

  var notifications = [
    NotificationItem(
        label: "All co-signers have joined Space's Account",
        created: DateTime.now().subtract(Duration(hours: 1))),
    NotificationItem(
        label: "Invitation Declined",
        created: DateTime.now().subtract(Duration(days: 1))),
  ];

  Stream<ActionListBlocState> get stream => _streamController.stream;

  void init() {
    _connectQueueService.addListener(_onActionQueueUpdated);

    Future.wait([_buildActionGroups(), _buildNotificationItems()])
        .then((results) {
      final actionGroups = results[0] as List<ActionListGroup>;
      final notifications = results[1] as List<NotificationItem>;

      _streamController.add(ActionListBlocState(actionGroups, notifications));
    });
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

  Future<List<ActionListGroup>> _buildActionGroups() async {
    final currentAccount = _accountService.events.selected.value;
    final accounts = await _accountService.getAccounts();
    final accountLookup = Map<String, Account>.fromIterable(accounts,
        key: (account) => account.publicKey.address,
        value: (account) => account);

    final queuedItems = await _connectQueueService.loadAllGroups();

    return queuedItems
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
            label = Strings.actionListLabelApproveSession;
          } else if (entry.value is SignRequest) {
            label = Strings.actionListLabelSignatureRequested;
          } else if (entry.value is SendRequest) {
            label = Strings.actionListLabelTransactionRequested;
          } else {
            label = Strings.actionListLabelUnknown;
          }
          return _WalletConnectActionItem(
              label: label,
              subLabel: Strings.actionListSubLabelActionRequired,
              payload: entry.value);
        }).toList(),
      );
    }).toList();
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

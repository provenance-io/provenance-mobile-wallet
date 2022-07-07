import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/services/models/requests/send_request.dart';
import 'package:provenance_wallet/services/models/requests/sign_request.dart';
import 'package:provenance_wallet/services/models/wallet_connect_session_request_data.dart';
import 'package:provenance_wallet/services/wallet_connect_queue_service/wallet_connect_queue_service.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

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
  final WalletConnectQueueService _connectQueueService;
  final AccountService _accountService;

  final _streamController = StreamController<ActionListBlocState>();

  ActionListBloc()
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
    Future.wait([_buildActionGroups(), _buildNotificationItems()])
        .then((results) {
      final actionGroups = results[0] as List<ActionListGroup>;
      final notifications = results[1] as List<NotificationItem>;

      _streamController.add(ActionListBlocState(actionGroups, notifications));
    });
  }

  @override
  FutureOr onDispose() {
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

    return queuedItems.map((queuedItem) {
      final account = accountLookup[queuedItem.walletAddress];
      return ActionListGroup(
        label: account!.name,
        subLabel: queuedItem.walletAddress.abbreviateAddress(),
        isSelected: currentAccount!.id == account.id,
        isBasicAccount: account.kind == AccountKind.basic,
        items: queuedItem.actionLookup.entries.map((entry) {
          String label;
          if (entry.value is WalletConnectSessionRequestData) {
            label = "Approve Session";
          } else if (entry.value is SignRequest) {
            label = "Signature Requested";
          } else if (entry.value is SendRequest) {
            label = "Transaction Requested";
          } else {
            label = "Unknown";
          }
          return ActionListItem(label: label, subLabel: "Action Required");
        }).toList(),
      );
    }).toList();
  }
}

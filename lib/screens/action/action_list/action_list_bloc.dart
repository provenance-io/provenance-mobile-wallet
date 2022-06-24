import 'dart:async';

import 'package:get_it/get_it.dart';

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
  final _streamController = StreamController<ActionListBlocState>();

  var actionGroups = [
    ActionListGroup(
        label: "Honey's Wallet",
        subLabel: "(2in...13nAq)",
        isSelected: true,
        isBasicAccount: false,
        items: [
          ActionListItem(label: "Send Hash", subLabel: "Action Required"),
          ActionListItem(
              label: "Resend Invitation", subLabel: "Action Required"),
        ]),
    ActionListGroup(
        label: "Junior's Wallet",
        subLabel: "(qw3...12hf)",
        isSelected: false,
        isBasicAccount: true,
        items: [
          ActionListItem(
              label: "Invitation Declined", subLabel: "Action Required"),
        ]),
    ActionListGroup(
        label: "Yuzu's Account",
        subLabel: "(dwh...1qjkh)",
        isSelected: false,
        isBasicAccount: false,
        items: [
          ActionListItem(label: "Send Hash", subLabel: "Action Required"),
          ActionListItem(label: "Add Marker", subLabel: "Action Required"),
        ]),
  ];

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
    _streamController.add(ActionListBlocState(actionGroups, notifications));
  }

  @override
  FutureOr onDispose() {
    _streamController.close();
  }

  Future<void> deleteNotifications(List<NotificationItem> notifications) {
    this.notifications = this.notifications.where((item) {
      return !notifications.contains(item);
    }).toList();

    _streamController
        .add(ActionListBlocState(actionGroups, this.notifications));
    return Future.value();
  }
}

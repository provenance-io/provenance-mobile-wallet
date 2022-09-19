import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/common/widgets/pw_dialog.dart';
import 'package:provenance_wallet/screens/action/action_list/action_list.dart';
import 'package:provenance_wallet/screens/action/action_list/action_list_bloc.dart';
import 'package:provenance_wallet/screens/action/action_list/notification_list.dart';
import 'package:provenance_wallet/services/account_notification_service/account_notification_service.dart';
import 'package:provenance_wallet/services/account_notification_service/notification_item.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:provider/provider.dart';

class ActionListTab extends StatelessWidget {
  const ActionListTab({required this.label, required this.count, Key? key})
      : super(key: key);

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Spacing.small),
      child: Text(
        "$label ($count)",
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.fade,
      ),
    );
  }
}

class ActionListScreen extends StatefulWidget {
  const ActionListScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ActionListScreenState();
}

class ActionListScreenState extends State<ActionListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _notificationService = get<AccountNotificationService>();

  @override
  void initState() {
    super.initState();

    _tabController = TabController(vsync: this, length: 2);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<ActionListBloc>(context, listen: false);

    return Scaffold(
        appBar: PwAppBar(),
        body: StreamBuilder<ActionListBlocState>(
            stream: bloc.stream,
            builder: (context, snapshot) {
              if (snapshot.data == null) {
                return Container();
              }

              final state = snapshot.data!;

              return Padding(
                padding: const EdgeInsets.all(Spacing.small),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TabBar(
                      tabs: [
                        ActionListTab(
                            label:
                                Strings.of(context).actionListActionsCellTitle,
                            count: state.actionGroups.length),
                        StreamBuilder<List<NotificationItem>>(
                            initialData:
                                _notificationService.notifications.valueOrNull,
                            stream: _notificationService.notifications,
                            builder: (context, snapshot) {
                              final notificationCount =
                                  snapshot.data?.length ?? 0;

                              return ActionListTab(
                                label: Strings.of(context)
                                    .actionListNotificationsCellTitle,
                                count: notificationCount,
                              );
                            }),
                      ],
                      controller: _tabController,
                    ),
                    Expanded(
                        child:
                            TabBarView(controller: _tabController, children: [
                      ActionList(groups: state.actionGroups),
                      StreamBuilder<List<NotificationItem>>(
                          initialData:
                              _notificationService.notifications.valueOrNull,
                          stream: _notificationService.notifications,
                          builder: (context, snapshot) {
                            final notifications = snapshot.data;
                            if (notifications == null) {
                              return Container();
                            }

                            return NotificationList(
                              items: notifications,
                              onItemsDeleted: (v) =>
                                  _onDeleteNotificationItems(context, v),
                            );
                          })
                    ]))
                  ],
                ),
              );
            }));
  }

  Future<void> _onDeleteNotificationItems(
      BuildContext context, List<NotificationItem> deletedItems) async {
    final delete = await PwDialog.showConfirmation(
      context,
      cancelText: Strings.of(context).cancel,
      confirmText: Strings.of(context).deleteConfirmationDeleteTitle,
      header: PwText(Strings.of(context).deleteConfirmationTitle),
      content: PwText(Strings.of(context).deleteConfirmationMessage),
    );

    if (!delete) {
      return;
    }

    final ids = deletedItems.map((e) => e.id).toList();

    await _notificationService.delete(ids: ids);
  }
}

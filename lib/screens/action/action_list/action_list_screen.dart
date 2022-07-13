import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/common/widgets/pw_dialog.dart';
import 'package:provenance_wallet/screens/action/action_list/action_list.dart';
import 'package:provenance_wallet/screens/action/action_list/action_list_bloc.dart';
import 'package:provenance_wallet/screens/action/action_list/notification_list.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

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
    final bloc = get<ActionListBloc>();

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
                            label: Strings.actionListActionsCellTitle,
                            count: state.actionGroups.length),
                        ActionListTab(
                            label: Strings.actionListNotificationsCellTitle,
                            count: state.notificationGroups.length),
                      ],
                      controller: _tabController,
                    ),
                    Expanded(
                        child:
                            TabBarView(controller: _tabController, children: [
                      ActionList(groups: state.actionGroups),
                      NotificationList(
                        items: state.notificationGroups,
                        onItemsDeleted: _onDeleteNotificationItems,
                      )
                    ]))
                  ],
                ),
              );
            }));
  }

  Future<void> _onDeleteNotificationItems(
      List<NotificationItem> deletedItems) async {
    final delete = await PwDialog.showConfirmation(
      context,
      cancelText: Strings.cancel,
      confirmText: Strings.deleteConfirmationDeleteTitle,
      header: PwText(Strings.deleteConfirmationTitle),
      content: PwText(Strings.deleteConfirmationMessage),
    );

    if (!delete) {
      return;
    }
    final bloc = get<ActionListBloc>();
    return bloc.deleteNotifications(deletedItems);
  }
}

import 'package:intl/intl.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_divider.dart';
import 'package:provenance_wallet/common/widgets/pw_link_text.dart';
import 'package:provenance_wallet/services/account_notification_service/notification_item.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:url_launcher/url_launcher_string.dart';

const _checkBoxSize = 40.0;

///
/// a widget that represents an instance of a notification
///
class NotificationItemCell extends StatelessWidget {
  static final notificationListFormatter = DateFormat("MMM dd, yyyy").add_Hms();

  NotificationItemCell(
      {required this.item,
      required this.isSelected,
      required Animation<double> animation,
      Key? key})
      : slideAnimation =
            Tween<Offset>(begin: Offset(-_checkBoxSize, 0), end: Offset.zero)
                .animate(animation),
        super(key: key);

  final NotificationItem item;
  final ValueNotifier<bool> isSelected;
  final Animation<Offset> slideAnimation;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: AnimatedBuilder(
          animation: slideAnimation,
          builder: (context, child) {
            return Transform.translate(
                offset: slideAnimation.value, child: child);
          },
          child: Row(
            children: [
              SizedBox(
                width: _checkBoxSize,
                child: ValueListenableBuilder<bool>(
                    valueListenable: isSelected,
                    builder: (context, value, child) {
                      return Checkbox(
                          value: value,
                          onChanged: (newValue) =>
                              isSelected.value = newValue!);
                    }),
              ),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PwLinkText(
                    text: item.label.get(context),
                    onTap: (String uri) {
                      launchUrlString(uri);
                    },
                  ),
                  PwText(
                    notificationListFormatter.format(item.created),
                    style: PwTextStyle.footnote,
                    color: PwColor.neutral200,
                  ),
                ],
              )),
            ],
          )),
    );
  }
}

typedef NotificationItemsDelegate = void Function(List<NotificationItem> items);

///
/// A List notifications with the ability to delete them
///
class NotificationList extends StatefulWidget {
  const NotificationList(
      {required this.items, required this.onItemsDeleted, Key? key})
      : super(key: key);

  final List<NotificationItem> items;
  final NotificationItemsDelegate onItemsDeleted;

  @override
  State<StatefulWidget> createState() => NotificationListState();
}

class NotificationListState extends State<NotificationList>
    with
        SingleTickerProviderStateMixin,
        AutomaticKeepAliveClientMixin<NotificationList> {
  static final _animationDuration = Duration(milliseconds: 200);

  final _isEdittingController = ValueNotifier<bool>(false);
  final _isSelectedMap = <NotificationItem, ValueNotifier<bool>>{};
  late AnimationController _animationController;
  late Animation<Offset> _buttonAnimation;

  @override
  void initState() {
    super.initState();

    _animationController =
        AnimationController(vsync: this, duration: _animationDuration);

    _buttonAnimation = Tween(begin: Offset(0, 1), end: Offset.zero)
        .animate(_animationController);

    _isEdittingController.addListener(() {
      if (_isEdittingController.value) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });

    for (var item in widget.items) {
      _isSelectedMap[item] = ValueNotifier<bool>(false);
    }
  }

  @override
  void didUpdateWidget(covariant NotificationList oldWidget) {
    super.didUpdateWidget(oldWidget);

    for (var item in widget.items) {
      _isSelectedMap.putIfAbsent(item, () => ValueNotifier<bool>(false));
    }

    final removedNotifications = _isSelectedMap.keys
        .where((notification) => !widget.items.contains(notification))
        .toList();

    for (var item in removedNotifications) {
      _isSelectedMap.remove(item);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
              child: Column(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: Spacing.small,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            child: PwText(Strings.of(context)
                                .notificationListStatusLabel)),
                        ValueListenableBuilder<bool>(
                            valueListenable: _isEdittingController,
                            builder: (context, value, child) {
                              return (value)
                                  ? Container()
                                  : PwTextButton.shrinkWrap(
                                      child: PwText(
                                        Strings.of(context)
                                            .notificationListEditLabel,
                                      ),
                                      onPressed: () {
                                        _isEdittingController.value =
                                            !_isEdittingController.value;
                                      },
                                    );
                            })
                      ],
                    ),
                  ),
                  PwDivider(),
                  ListView.separated(
                      shrinkWrap: true,
                      itemCount: widget.items.length,
                      separatorBuilder: (context, index) => const PwDivider(),
                      itemBuilder: (context, index) {
                        final item = widget.items[index];
                        return NotificationItemCell(
                          item: item,
                          isSelected: _isSelectedMap[item]!,
                          animation: _animationController,
                          key: ValueKey(index),
                        );
                      }),
                ],
              ),
            ],
          )),
        ),
        SlideTransition(
          position: _buttonAnimation,
          child: SafeArea(
            child: Column(children: [
              PwTextButton.primaryAction(
                context: context,
                text: "Delete",
                onPressed: _deleteSelected,
              ),
              VerticalSpacer.large(),
              PwTextButton.secondaryAction(
                context: context,
                text: "Cancel",
                onPressed: _cancelClicked,
              ),
              VerticalSpacer.large(),
            ]),
          ),
        )
      ],
    );
  }

  Future<void> _deleteSelected() async {
    final deletedList = _isSelectedMap.entries
        .where((entry) => entry.value.value)
        .map((e) => e.key)
        .toList();

    widget.onItemsDeleted(deletedList);
  }

  void _cancelClicked() {
    _isEdittingController.value = false;
  }

  @override
  bool get wantKeepAlive => true;
}

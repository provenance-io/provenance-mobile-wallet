import 'package:provenance_blockchain_wallet/common/pw_design.dart';
import 'package:provenance_blockchain_wallet/services/notification/notification_info.dart';
import 'package:provenance_blockchain_wallet/services/notification/notification_kind.dart';
import 'package:provenance_blockchain_wallet/services/notification/notification_service.dart';
import 'package:provenance_blockchain_wallet/util/get.dart';

class NotificationBar extends StatelessWidget {
  const NotificationBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final service = get<NotificationService>();

    return StreamBuilder<List<NotificationInfo>>(
      initialData: service.notifications.value,
      stream: service.notifications,
      builder: (context, snapshot) {
        final notifications = snapshot.data!;
        final notification = notifications.isEmpty ? null : notifications.last;

        Widget child;

        if (notification == null) {
          child = Container();
        } else {
          final id = notification.id;
          final title = notification.title;
          final message = notification.message;
          final kind = notification.kind;
          final count = notification.count;

          final icon = _getIcon(context, kind);
          final backgroundColor = _getBackgroundColor(context, kind);

          child = GestureDetector(
            onTap: () {
              service.dismiss(id);
            },
            child: Container(
              margin: EdgeInsets.only(
                top: Spacing.large,
                bottom: Spacing.large,
              ),
              padding: EdgeInsets.symmetric(
                vertical: Spacing.large,
                horizontal: Spacing.xxLarge,
              ),
              color: backgroundColor,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      textDirection: TextDirection.ltr,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            PwText(
                              title,
                              style: PwTextStyle.subhead,
                              color: PwColor.notice800,
                              textAlign: TextAlign.left,
                            ),
                            if (count != null)
                              Container(
                                margin: EdgeInsets.only(
                                  left: Spacing.small,
                                ),
                                padding: EdgeInsets.only(
                                  top: 1,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color:
                                      Theme.of(context).colorScheme.notice800,
                                ),
                                alignment: Alignment.center,
                                width: 20,
                                height: 20,
                                child: PwText(
                                  count.toString(),
                                  style: PwTextStyle.body,
                                  textAlign: TextAlign.center,
                                  color: PwColor.notice350,
                                ),
                              ),
                          ],
                        ),
                        if (message != null)
                          Container(
                            margin: EdgeInsets.only(
                              top: Spacing.xSmall,
                            ),
                            child: PwText(
                              message,
                              textAlign: TextAlign.left,
                              style: PwTextStyle.body,
                              color: PwColor.notice800,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (icon != null)
                    Container(
                      margin: EdgeInsets.only(
                        left: Spacing.large,
                      ),
                      child: icon,
                    ),
                ],
              ),
            ),
          );
        }

        return AnimatedSwitcher(
          duration: Duration(
            milliseconds: 300,
          ),
          child: child,
        );
      },
    );
  }

  Color _getBackgroundColor(BuildContext context, NotificationKind kind) {
    Color color;
    switch (kind) {
      case NotificationKind.warn:
        color = Theme.of(context).colorScheme.notice350;
        break;
    }

    return color;
  }

  PwIcon? _getIcon(BuildContext context, NotificationKind? kind) {
    String? iconPath;
    switch (kind) {
      case NotificationKind.warn:
        iconPath = PwIcons.warn;
        break;
      default:
        iconPath = null;
        break;
    }

    final icon = iconPath == null
        ? null
        : PwIcon(
            iconPath,
            color: Theme.of(context).colorScheme.neutral800,
            size: 24,
          );

    return icon;
  }
}

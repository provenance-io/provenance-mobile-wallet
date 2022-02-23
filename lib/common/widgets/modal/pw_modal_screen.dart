import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/modal/pw_modal_message.dart';

class PwModalScreen {
  PwModalScreen._();

  ///
  /// A fullscreen modal with two buttons; approve and decline.
  ///
  /// Blocks the back button, requiring a selection.
  ///
  static Future<bool> showConfirm({
    required BuildContext context,
    required String title,
    required String approveText,
    required String declineText,
    String? message,
    Widget? icon,
  }) async {
    final result = await showGeneralDialog<bool>(
      context: context,
      pageBuilder: (
        context,
        animation,
        secondaryAnimation,
      ) {
        return Material(
          child: WillPopScope(
            onWillPop: () async => false,
            child: PwModalMessage(
              title: title,
              message: message,
              icon: icon,
              actions: Container(
                margin: EdgeInsets.symmetric(
                  horizontal: Spacing.large,
                ),
                child: Column(
                  children: [
                    PwTextButton.primaryAction(
                      context: context,
                      text: approveText,
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                    ),
                    VerticalSpacer.large(),
                    PwTextButton.secondaryAction(
                      context: context,
                      text: declineText,
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    return result ?? false;
  }

  ///
  /// A fullscreen modal with a single confirmation button.
  ///
  static Future<void> showNotify({
    required BuildContext context,
    required String title,
    required String buttonText,
    String? message,
    Widget? icon,
    bool barrierDismissible = true,
  }) {
    return showGeneralDialog(
      context: context,
      pageBuilder: (
        context,
        animation,
        secondaryAnimation,
      ) {
        return Material(
          child: WillPopScope(
            onWillPop: () async => barrierDismissible,
            child: PwModalMessage(
              title: title,
              message: message,
              icon: icon,
              actions: Container(
                margin: EdgeInsets.symmetric(
                  horizontal: Spacing.large,
                ),
                child: PwTextButton.primaryAction(
                  context: context,
                  text: buttonText,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

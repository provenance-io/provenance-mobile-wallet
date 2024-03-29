import 'package:provenance_wallet/common/classes/pw_error.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/dialogs/error_dialog.dart';
import 'package:provenance_wallet/util/assets.dart';
import 'package:provenance_wallet/util/strings.dart';

class PwDialog {
  PwDialog._();

  static Future<T?> showFull<T>({
    required BuildContext context,
    required String title,
    String? message,
    Widget? icon,
    String dismissButtonText = 'Back to Account',
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
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(Assets.imagePaths.background),
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: Spacing.large,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            PwText(
                              title.toUpperCase(),
                              style: PwTextStyle.headline2,
                              color: PwColor.neutralNeutral,
                              textAlign: TextAlign.center,
                            ),
                            if (message != null) VerticalSpacer.large(),
                            if (message != null)
                              PwText(
                                message,
                                style: PwTextStyle.body,
                                color: PwColor.neutralNeutral,
                                textAlign: TextAlign.center,
                              ),
                            if (icon != null) VerticalSpacer.xxLarge(),
                            if (icon != null) icon,
                          ],
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: Spacing.large,
                      ),
                      child: PwTextButton.primaryAction(
                        context: context,
                        text: dismissButtonText,
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                    VerticalSpacer.large(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Foundational design function for displaying dialogs. Only use when [showError],
  /// [showConfirmation], or [showMessage] can't be used
  /// Note: [content] supercedes [message]
  static Future<T?> show<T>(
    BuildContext context, {
    Widget? header,
    String? title,
    String? message,
    Widget? content,
    Widget? bottom,
    bool barrierDismissible = true,
    Color? barrierColor,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor ?? Theme.of(context).colorScheme.neutral750,
      useRootNavigator: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => barrierDismissible,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.neutral750,
            elevation: 0.0,
            title: header ??
                PwText(
                  title ?? Strings.of(context).appName,
                  style: PwTextStyle.footnote,
                  textAlign: TextAlign.left,
                ),
            centerTitle: true,
            leading: Container(),
          ),
          body: Container(
            color: Theme.of(context).colorScheme.neutral750,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.all(
                    Spacing.large,
                  ),
                  child: content ??
                      PwText(
                        message ?? "",
                        style: PwTextStyle.body,
                        color: PwColor.neutralNeutral,
                        textAlign: TextAlign.center,
                      ),
                ),
                Expanded(child: Container()),
                bottom ??
                    Padding(
                      padding: EdgeInsets.only(left: 20, right: 20),
                      child: PwButton(
                        child: PwText(
                          Strings.of(context).confirm,
                          style: PwTextStyle.bodyBold,
                          color: PwColor.neutralNeutral,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop(null);
                        },
                      ),
                    ),
                VerticalSpacer.large(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Future<void> showError({
    required BuildContext context,
    String? title,
    String? message,
    String? buttonText,
    Object? error,
  }) {
    final msg = message ??
        ((error is PwError)
            ? error.toLocalizedString(context)
            : error?.toString().replaceFirst(
                  RegExp("^.*: "),
                  "",
                ));

    return showDialog(
      context: context,
      useSafeArea: true,
      builder: (context) {
        return ErrorDialog(
          title: title,
          error: msg,
          buttonText: buttonText,
        );
      },
    );
  }

  /// Shows user a confirmation dialog and returns the result as a [bool].
  /// [content] supercedes [message]
  static Future<bool> showConfirmation(
    BuildContext context, {
    Widget? header,
    String? title,
    String? message,
    Widget? content,
    String? confirmText,
    String? cancelText,
    Widget? footer,
  }) async {
    final result = await show<bool>(
      context,
      barrierDismissible: false,
      header: header,
      title: title ?? Strings.of(context).appName,
      message: message,
      content: content,
      bottom: Padding(
        padding: EdgeInsets.symmetric(horizontal: Spacing.xLarge),
        child: Column(
          children: [
            PwPrimaryButton.fromString(
              text: confirmText ?? cancelText ?? Strings.of(context).cancel,
              onPressed: () => Navigator.of(context).pop(true),
            ),
            const VerticalSpacer.small(),
            if (confirmText != null) ...[
              PwTextButton(
                child: PwText(cancelText ?? Strings.of(context).cancel),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              if (footer != null) ...[
                const VerticalSpacer.small(),
                footer,
              ],
            ],
          ],
        ),
      ),
    );

    return result ?? false;
  }

  /// Shows an alert message to user. Uses [showConfirmation] under the hood
  /// for consistency
  static Future<void> showMessage(
    BuildContext context, {
    Widget? header,
    String? title,
    String? closeText,
    required String message,
  }) {
    return showConfirmation(
      context,
      header: header,
      title: title,
      message: message,
      cancelText: closeText ?? Strings.of(context).continueName,
    );
  }
}

import 'package:provenance_dart/wallet_connect.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/util/assets.dart';
import 'package:provenance_wallet/util/strings.dart';

class PwDialog {
  PwDialog._();

  static Future<T?> showFull<T>({
    required BuildContext context,
    required String title,
    String? message,
    Widget? icon,
    String dismissButtonText = 'Back to Wallet',
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
                          horizontal: Spacing.xxLarge,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
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
    String title = Strings.appName,
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
                  title,
                  style: PwTextStyle.subhead,
                  textAlign: TextAlign.left,
                ),
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
                    Spacing.xxLarge,
                  ),
                  child: content ??
                      PwText(
                        message ?? "",
                        style: PwTextStyle.body,
                        color: PwColor.neutralNeutral,
                      ),
                ),
                Expanded(child: Container()),
                bottom ??
                    Padding(
                      padding: EdgeInsets.only(left: 20, right: 20),
                      child: PwButton(
                        child: PwText(
                          Strings.confirm,
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

  static Future<T?> showError<T>(
    BuildContext context, {
    String title = 'Oops!',
    String? message,
    Exception? exception,
    dynamic error,
    VoidCallback? okAction,
    bool showCancel = false,
  }) {
    final msg = message ??= exception?.toString().replaceFirst(
          RegExp("^.*: "),
          "",
        );

    return show<T>(
      context,
      barrierDismissible: false,
      title: title,
      message: msg ?? 'Unknown Error',
      bottom: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: Spacing.xLarge,
            ),
            child: PwPrimaryButton.fromString(
              text: Strings.okay,
              onPressed: () {
                Navigator.of(context).pop();
                okAction?.call();
              },
            ),
          ),
          if (showCancel) ...[
            const VerticalSpacer.small(),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: Spacing.xLarge,
              ),
              child: PwTextButton(
                child: PwText(Strings.cancel),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ],
      ),
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
    String cancelText = Strings.cancel,
    Widget? footer,
  }) async {
    final result = await show<bool>(
      context,
      barrierDismissible: false,
      header: header,
      title: title ?? Strings.appName,
      message: message,
      content: content,
      bottom: Padding(
        padding: EdgeInsets.symmetric(horizontal: Spacing.xLarge),
        child: Column(
          children: [
            PwPrimaryButton.fromString(
              text: confirmText ?? cancelText,
              onPressed: () => Navigator.of(context).pop(true),
            ),
            const VerticalSpacer.small(),
            if (confirmText != null) ...[
              PwTextButton(
                child: PwText(cancelText),
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
    String closeText = Strings.continueName,
    required String message,
  }) {
    return showConfirmation(
      context,
      header: header,
      title: title,
      message: message,
      cancelText: closeText,
    );
  }

  static Future<bool> showSessionConfirmation(
    BuildContext context,
    SessionRequestData data,
  ) async {
    final result = await show<bool>(
      context,
      barrierDismissible: false,
      title: data.clientMeta.name,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (data.clientMeta.icons.isNotEmpty)
            Image.network(
              data.clientMeta.icons.first,
            ),
          PwText(
            data.clientMeta.description,
            textAlign: TextAlign.center,
          ),
        ],
      ),
      bottom: Column(
        children: [
          PwPrimaryButton.fromString(
            text: Strings.sessionApprove,
            onPressed: () => Navigator.of(context).pop(true),
          ),
          const VerticalSpacer.small(),
          PwTextButton(
            child: PwText(Strings.sessionReject),
            onPressed: () => Navigator.of(context).pop(false),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}

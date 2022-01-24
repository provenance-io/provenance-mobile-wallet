import 'dart:io';

import 'package:provenance_wallet/common/fw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:url_launcher/url_launcher.dart';

class FwDialog {
  FwDialog._();

  /// Foundational design function for displaying dialogs. Only use when [showError],
  /// [showConfirmation], or [showMessage] can't be used
  /// Note: [content] supercedes [message]
  static Future<T?> show<T>(
    BuildContext context, {
    Widget? header,
    String title = 'Figure Tech Wallet',
    String? message,
    Widget? content,
    Widget? bottom,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: Theme.of(context).colorScheme.black.withOpacity(0.8),
      useRootNavigator: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => barrierDismissible,
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Padding(
            padding: EdgeInsets.only(
              top: header == null ? Spacing.medium : Spacing.large,
              left: Spacing.medium,
              right: Spacing.medium,
            ),
            child: Column(
              children: [
                if (header != null) ...[
                  header,
                  const VerticalSpacer.xLarge(),
                ],
                FwText(
                  title,
                  style: FwTextStyle.h4,
                  color: FwColor.black,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          content: content ??
              (message != null
                  ? FwText(
                      message,
                      style: FwTextStyle.m,
                      color: FwColor.black,
                      textAlign: TextAlign.center,
                    )
                  : null),
          insetPadding: const EdgeInsets.symmetric(horizontal: Spacing.medium),
          contentPadding: EdgeInsets.only(
            top: Spacing.medium,
            bottom: content == null ? Spacing.large : 0.0,
            left: Spacing.medium,
            right: Spacing.medium,
          ),
          actions: [
            if (bottom != null) ...[
              Padding(
                padding: const EdgeInsets.all(Spacing.small),
                child: bottom,
              ),
            ],
          ],
        ),
      ),
    );
  }

  static Future<T?> showError<T>(
    BuildContext context, {
    String title = 'Oops!',
    String? message,
    dynamic error,
    VoidCallback? okAction,
    bool showCancel = false,
  }) {
    return show<T>(
      context,
      barrierDismissible: false,
      title: title,
      message: message ?? 'Unknown Error',
      bottom: Column(
        children: [
          FwPrimaryButton(
            child: FwText('OK'),
            onPressed: () {
              Navigator.of(context).pop();
              okAction?.call();
            },
          ),
          if (showCancel) ...[
            const VerticalSpacer.small(),
            FwTextButton(
              child: FwText('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
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
    String cancelText = 'Cancel',
    Widget? footer,
  }) async {
    final result = await show<bool>(
      context,
      barrierDismissible: false,
      header: header,
      title: title ?? 'Figure Tech Wallet',
      message: message,
      content: content,
      bottom: Column(
        children: [
          FwPrimaryButton(
            child: FwText(confirmText ?? cancelText),
            onPressed: () => Navigator.of(context).pop(true),
          ),
          const VerticalSpacer.small(),
          if (confirmText != null) ...[
            FwTextButton(
              child: FwText(cancelText),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            if (footer != null) ...[
              const VerticalSpacer.small(),
              footer,
            ],
          ],
        ],
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
    String closeText = 'Close',
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

  // Below are specific dialogs that are used more than once in various places.
  // Could possible cleanup (move to specific views) as things change/ get cleaned.

  static Future<void> showBiometricsDialog(
    BuildContext context,
    String authType,
  ) {
    return showMessage(
      context,
      title: 'Oops',
      message:
          'Sorry, you need to have $authType enabled on your device in order to use Figure Pay.',
    );
  }

  static Future<void> showUpdateNeeded(
    BuildContext context, {
    required VoidCallback onTap,
  }) {
    return show(
      context,
      barrierDismissible: false,
      title: 'Update Needed',
      content: GestureDetector(
        onTap: onTap,
        child: const FwText(
          'Please update to the latest version of Figure Tech Wallet in order to continue using the app. Thank you!',
          style: FwTextStyle.m,
          color: FwColor.black,
          textAlign: TextAlign.center,
        ),
      ),
      bottom: FwPrimaryButton(
        child: FwText('Force Update'),
        onPressed: () {
          final url = Platform.isIOS
              ? 'https://apps.apple.com/us/app/figure-pay/id1529369990'
              : 'https://play.google.com/store/apps/details?id=com.figure.mobile.figurepay';
          launch(url);
        },
      ),
    );
  }
}

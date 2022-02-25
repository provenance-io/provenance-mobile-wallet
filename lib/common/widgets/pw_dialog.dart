import 'dart:io';

import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/services/remote_client_details.dart';
import 'package:provenance_wallet/util/assets.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:url_launcher/url_launcher.dart';

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
                  image: AssetImage(AssetPaths.images.background),
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
                              title,
                              style: PwTextStyle.headline2,
                              color: PwColor.neutralNeutral,
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
    String title = 'Provenance Wallet',
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
                PwText(
                  title,
                  style: PwTextStyle.h4,
                  color: PwColor.black,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          content: content ??
              (message != null
                  ? PwText(
                      message,
                      style: PwTextStyle.m,
                      color: PwColor.black,
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
          PwPrimaryButton.fromString(
            text: 'OK',
            onPressed: () {
              Navigator.of(context).pop();
              okAction?.call();
            },
          ),
          if (showCancel) ...[
            const VerticalSpacer.small(),
            PwTextButton(
              child: PwText('Cancel'),
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

  static Future<bool> showSessionConfirmation(
    BuildContext context,
    RemoteClientDetails remoteClientDetails,
  ) async {
    final result = await show<bool>(
      context,
      barrierDismissible: false,
      title: remoteClientDetails.name,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (remoteClientDetails.icons.isNotEmpty)
            Image.network(
              remoteClientDetails.icons.first,
            ),
          PwText(
            remoteClientDetails.description,
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

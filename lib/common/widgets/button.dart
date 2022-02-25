import 'package:provenance_wallet/common/pw_design.dart';

class PwPrimaryButton extends StatelessWidget {
  const PwPrimaryButton({
    Key? key,
    required this.child,
    this.onPressed,
    this.minimumWidth = double.maxFinite,
  }) : super(key: key);

  /// The child to display within the button. This is often just a Text widget.
  final Widget child;

  /// The callback to invoke when the button is pressed.
  final VoidCallback? onPressed;

  /// Useful when working with Flexible/Expandable widgets
  final double minimumWidth;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ButtonStyle(
        foregroundColor:
            MaterialStateProperty.all(Theme.of(context).colorScheme.onPrimary),
        backgroundColor:
            MaterialStateProperty.resolveWith((Set<MaterialState> states) {
          if (states.contains(MaterialState.disabled)) {
            return Theme.of(context).colorScheme.primary400.withOpacity(0.4);
          }

          return showAlternate
              ? Theme.of(context).colorScheme.primary400
              : Theme.of(context).colorScheme.primary;
        }),
        // FIXME: Border should appear on the outside as per design
        side: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
          if (states.contains(MaterialState.focused) ||
              states.contains(MaterialState.hovered) ||
              states.contains(MaterialState.pressed)) {
            return BorderSide(
              color: Theme.of(context).colorScheme.primary400,
              width: 8,
            );
          }
        }),
        minimumSize: MaterialStateProperty.all(
          Size(
            minimumWidth,
            50,
          ),
        ),
      ),
      onPressed: onPressed,
      child: child,
    );
  }
}

class PwButton extends StatelessWidget {
  const PwButton({
    Key? key,
    required this.child,
    this.enabled = true,
    required this.onPressed,
    this.showAlternate = false,
    this.minimumWidth = double.maxFinite,
  }) : super(key: key);

  const PwButton.alternate({
    Key? key,
    required Widget child,
    bool enabled = true,
    required VoidCallback onPressed,
    double minimumWidth = double.maxFinite,
  }) : this(
          key: key,
          child: child,
          enabled: enabled,
          onPressed: onPressed,
          minimumWidth: minimumWidth,
          showAlternate: true,
        );

  /// The child to display within the button. This is often just a Text widget.
  final Widget child;

  /// Explicit value instead of setting null to [onPressed]
  final bool enabled;

  /// The callback to invoke when the button is pressed.
  final VoidCallback onPressed;

  /// Used to show an alternate version of the button, as per the figma design
  final bool showAlternate;

  /// Useful when working with Flexible/Expandable widgets
  final double minimumWidth;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: _buttonStyle(context),
      onPressed: enabled ? onPressed : null,
      child: child,
    );
  }

  ButtonStyle _buttonStyle(BuildContext context) {
    final theme = Theme.of(context);

    return ButtonStyle(
      foregroundColor: MaterialStateProperty.resolveWith((states) {
        return theme.colorScheme.neutralNeutral;
      }),
      backgroundColor: MaterialStateProperty.resolveWith((states) {
        return showAlternate
            ? Colors.transparent
            : theme.colorScheme.primary550;
      }),
      side: MaterialStateProperty.resolveWith((states) {
        return showAlternate
            ? BorderSide(color: theme.colorScheme.primary500, width: 1)
            : null;
      }),
      minimumSize: MaterialStateProperty.all(
        Size(
          minimumWidth,
          50,
        ),
      ),
    );
  }
}

class PwTextButton extends StatelessWidget {
  const PwTextButton({
    Key? key,
    required this.child,
    required this.onPressed,
    this.minimumSize = const Size(
      double.maxFinite,
      50,
    ),
    this.shrinkWrap = false,
    this.backgroundColor,
  }) : super(key: key);

  const PwTextButton.shrinkWrap({
    Key? key,
    required Widget child,
    required VoidCallback onPressed,
  }) : this(
          key: key,
          child: child,
          onPressed: onPressed,
          shrinkWrap: true,
        );

  factory PwTextButton.primaryAction({
    required BuildContext context,
    required VoidCallback onPressed,
    required String text,
    Key? key,
  }) {
    return PwTextButton(
      child: PwText(
        text,
        style: PwTextStyle.bodyBold,
        color: PwColor.neutralNeutral,
      ),
      backgroundColor: Theme.of(context).colorScheme.primary550,
      onPressed: onPressed,
    );
  }

  factory PwTextButton.secondaryAction({
    required BuildContext context,
    required VoidCallback onPressed,
    required String text,
    Key? key,
  }) {
    return PwTextButton(
      child: PwText(
        text,
        style: PwTextStyle.body,
        color: PwColor.neutralNeutral,
      ),
      backgroundColor: Colors.transparent,
      onPressed: onPressed,
    );
  }

  /// The child to display within the button. This is often just a Text widget.
  final Widget child;

  /// The callback to invoke when the button is pressed.
  final VoidCallback onPressed;

  /// Mininum size unless [shrinkWrap] is true
  final Size minimumSize;

  /// shrinks total size of button (tappable area) to text size. Usually used
  /// for action items
  final bool shrinkWrap;

  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: backgroundColor,
        minimumSize: shrinkWrap ? Size.zero : minimumSize,
        padding: shrinkWrap ? EdgeInsets.zero : null,
        tapTargetSize: shrinkWrap ? MaterialTapTargetSize.shrinkWrap : null,
      ),
      onPressed: onPressed,
      child: child,
    );
  }
}

class PwGreyButton extends StatelessWidget {
  const PwGreyButton({
    Key? key,
    required this.text,
    this.enabled = true,
    required this.onPressed,
    this.minimumWidth = double.maxFinite,
  }) : super(key: key);

  /// The child to display within the button. This is often just a Text widget.
  final String text;

  /// Explicit value instead of setting null to [onPressed]
  final bool enabled;

  /// The callback to invoke when the button is pressed.
  final VoidCallback onPressed;

  /// Useful when working with Flexible/Expandable widgets
  final double minimumWidth;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: _buttonStyle(context),
      onPressed: enabled ? onPressed : null,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: Spacing.small),
        child: PwText(
          text,
          style: PwTextStyle.bodyBold,
        ),
      ),
    );
  }

  ButtonStyle _buttonStyle(BuildContext context) {
    final theme = Theme.of(context);

    return ButtonStyle(
      foregroundColor: MaterialStateProperty.resolveWith((states) {
        return theme.colorScheme.neutralNeutral;
      }),
      backgroundColor: MaterialStateProperty.resolveWith((states) {
        return theme.colorScheme.neutral700;
      }),
      minimumSize: MaterialStateProperty.all(Size(
        minimumWidth,
        50,
      )),
      padding: MaterialStateProperty.all(
        EdgeInsets.symmetric(vertical: Spacing.large),
      ),
    );
  }
}

class PwOutlinedButton extends StatelessWidget {
  const PwOutlinedButton(
    this._text, {
    Key? key,
    required this.onPressed,
    this.icon,
    this.largeButton = false,
    this.showArrow = false,
    this.center = true,
    this.fpTextStyle,
    this.fpTextColor,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1,
  }) : super(key: key);

  final String _text;

  final VoidCallback? onPressed;

  /// An icon to appear to the left of [_text]
  final Widget? icon;

  /// A [largeButton] will have Spacing.large padding around them and slightly more rounded corners
  /// else the button will be of a standard height of 50px
  final bool largeButton;

  /// An arrow to appear on the right side of the button
  final bool showArrow;

  /// To center the [_text] and [icon]. If [showArrow] is true, that will not be centered
  final bool center;

  final PwTextStyle? fpTextStyle;
  final PwColor? fpTextColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: backgroundColor ?? Colors.transparent,
        primary: Theme.of(context).colorScheme.neutralNeutral,
        padding: EdgeInsets.zero,
        side: BorderSide(
          color: borderColor ?? Theme.of(context).colorScheme.lightGrey,
          width: borderWidth,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(largeButton ? 8 : 4)),
        ),
        minimumSize: const Size(
          double.maxFinite,
          50,
        ),
      ),
      onPressed: onPressed,
      child: Padding(
        padding:
            largeButton ? const EdgeInsets.all(Spacing.large) : EdgeInsets.zero,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: center ? Alignment.center : Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      icon ?? Container(),
                      icon != null
                          ? const HorizontalSpacer.medium()
                          : Container(),
                      PwText(
                        _text,
                        style: fpTextStyle ?? PwTextStyle.m,
                        color: fpTextColor ?? PwColor.darkGrey,
                      ),
                    ],
                  ),
                ),
                showArrow
                    ? Align(
                        alignment: Alignment.centerRight,
                        child: PwIcon(
                          PwIcons.back,
                          color: Theme.of(context).colorScheme.darkGrey,
                        ),
                      )
                    : Container(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

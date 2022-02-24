import 'package:provenance_wallet/common/pw_design.dart';

class PwPrimaryButton extends StatelessWidget {
  const PwPrimaryButton({
    Key? key,
    required this.child,
    this.onPressed,
    this.showAlternate = false,
    this.minimumWidth = double.maxFinite,
  }) : super(key: key);

  /// The child to display within the button. This is often just a Text widget.
  final Widget child;

  /// The callback to invoke when the button is pressed.
  final VoidCallback? onPressed;

  /// Used to show an alternate version of the button, as per the figma design
  final bool showAlternate;

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

class PwSecondaryButton extends StatelessWidget {
  const PwSecondaryButton({
    Key? key,
    required this.child,
    this.onPressed,
    this.showAlternate = false,
  }) : super(key: key);

  /// The child to display within the button. This is often just a Text widget.
  final Widget child;

  /// The callback to invoke when the button is pressed.
  final VoidCallback? onPressed;

  /// Used to show an alternate version of the button, as per the figma design
  final bool showAlternate;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ButtonStyle(
        foregroundColor:
            MaterialStateProperty.resolveWith((Set<MaterialState> states) {
          if (!showAlternate && !states.contains(MaterialState.disabled)) {
            return Theme.of(context).colorScheme.onBackground;
          }

          return Theme.of(context).colorScheme.onPrimary;
        }),
        backgroundColor:
            MaterialStateProperty.resolveWith((Set<MaterialState> states) {
          if (states.contains(MaterialState.disabled)) {
            return Theme.of(context).colorScheme.black.withOpacity(0.3);
          }

          return showAlternate
              ? Theme.of(context).colorScheme.black
              : Theme.of(context).colorScheme.onPrimary;
        }),
        side: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
          if (states.contains(MaterialState.focused) ||
              states.contains(MaterialState.hovered) ||
              states.contains(MaterialState.pressed)) {
            return BorderSide(
              color: Theme.of(context).colorScheme.primary400,
              width: 8,
            );
          }
          if (!states.contains(MaterialState.disabled)) {
            return BorderSide(
              color: Theme.of(context).colorScheme.black,
              width: 2,
            );
          }
        }),
        minimumSize: MaterialStateProperty.all(const Size(
          double.infinity,
          50,
        )),
      ),
      onPressed: onPressed,
      child: child,
    );
  }
}

class PwActionButton extends StatelessWidget {
  const PwActionButton({
    Key? key,
    this.child,
    required this.onPressed,
    this.outlined = false,
  })  : label = null,
        super(key: key);

  /// Helper constructor for creating a button with a label.
  const PwActionButton.withLabel({
    Key? key,
    this.child,
    required this.onPressed,
    required this.label,
    this.outlined = false,
  }) : super(key: key);

  /// A widget to show in the button. This is typically an [Icon] widget.
  final Widget? child;

  /// The callback to invoke when the button is Pressed.
  final VoidCallback? onPressed;

  /// A label to show underneath the button.
  final Widget? label;

  /// Show the outlined version of the button.
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Column(
      children: [
        FloatingActionButton(
          elevation: 0.0,
          backgroundColor: outlined
              ? theme.colorScheme.onBackground
              : theme.colorScheme.primary400,
          shape: outlined
              ? RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(56.0)),
                  side: BorderSide(
                    color: theme.colorScheme.neutralNeutral,
                    width: 1.0,
                  ),
                )
              : null,
          onPressed: onPressed,
          child: child,
        ),
        if (label != null)
          DefaultTextStyle(
            style: Theme.of(context)
                .textTheme
                .bodyText2!
                .copyWith(color: Theme.of(context).colorScheme.onPrimary),
            child: Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: label!,
            ),
          ),
      ],
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
        if (showAlternate) {
          return states.contains(MaterialState.disabled)
              ? theme.colorScheme.neutral450.withOpacity(0.5)
              : theme.colorScheme.neutral450;
        }

        return theme.colorScheme.neutralNeutral;
      }),
      backgroundColor: MaterialStateProperty.resolveWith((states) {
        return states.contains(MaterialState.disabled)
            ? showAlternate
                ? theme.colorScheme.primary550.withOpacity(0.5)
                : theme.colorScheme.primary550.withOpacity(0.4)
            : theme.colorScheme.primary550;
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
      child: PwText(text),
    );
  }

  ButtonStyle _buttonStyle(BuildContext context) {
    final theme = Theme.of(context);

    return ButtonStyle(
      foregroundColor: MaterialStateProperty.resolveWith((states) {
        return theme.colorScheme.onPrimary;
      }),
      backgroundColor: MaterialStateProperty.resolveWith((states) {
        return states.contains(MaterialState.disabled)
            ? theme.colorScheme.lightGrey.withOpacity(0.4)
            : theme.colorScheme.lightGrey;
      }),
      minimumSize: MaterialStateProperty.all(Size(
        minimumWidth,
        50,
      )),
    );
  }
}

class PwPrimaryAndTextButton extends StatelessWidget {
  const PwPrimaryAndTextButton({
    Key? key,
    required this.primaryButtonText,
    required this.primaryButtonOnPressed,
    required this.textButtonText,
    required this.textButtonOnPressed,
  }) : super(key: key);

  final String primaryButtonText;
  final Function()? primaryButtonOnPressed;
  final String textButtonText;
  final Function()? textButtonOnPressed;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      PwPrimaryButton(
        child: PwText(primaryButtonText),
        onPressed: primaryButtonOnPressed,
      ),
      const VerticalSpacer.small(),
      TextButton(
        onPressed: textButtonOnPressed,
        child: PwText(
          textButtonText,
          color: PwColor.primary4,
        ),
      ),
    ]);
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

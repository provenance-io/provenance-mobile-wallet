import 'package:provenance_wallet/common/pw_design.dart';

class PwEditCount extends StatelessWidget {
  const PwEditCount({
    required this.count,
    required this.onChanged,
    this.min,
    this.max,
    Key? key,
  }) : super(key: key);

  final int? min;
  final int? max;
  final int count;
  final void Function(int value) onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _CircleButton(
          icon: PwIcons.minus,
          onPressed:
              min != null && count == min ? null : () => onChanged(count - 1),
        ),
        Container(
          alignment: Alignment.center,
          width: 120,
          child: PwText(
            count.toString(),
            style: PwTextStyle.display2,
            color: PwColor.neutralNeutral,
          ),
        ),
        _CircleButton(
          icon: PwIcons.plus,
          onPressed:
              max != null && count == max ? null : () => onChanged(count + 1),
        ),
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    this.onPressed,
    Key? key,
  }) : super(key: key);

  static const disabledOpacity = .38;

  final String icon;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    var iconColor = Theme.of(context).colorScheme.neutralNeutral;

    if (onPressed == null) {
      iconColor = iconColor.withOpacity(disabledOpacity);
    }

    return SizedBox(
      width: 40,
      height: 40,
      child: TextButton(
        onPressed: onPressed,
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith((states) {
          final color = Theme.of(context).colorScheme.neutral700;

          if (states.contains(MaterialState.disabled)) {
            return color.withOpacity(disabledOpacity);
          }

          return color;
        }), overlayColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.hovered)) {
            return Theme.of(context).colorScheme.neutralNeutral.withOpacity(.2);
          }

          return null;
        }), shape: MaterialStateProperty.resolveWith((states) {
          var color = Theme.of(context).colorScheme.neutral250;

          if (states.contains(MaterialState.disabled)) {
            color = color.withOpacity(disabledOpacity);
          }

          return CircleBorder(
            side: BorderSide(
              color: color,
            ),
          );
        })),
        child: Container(
          padding: EdgeInsets.all(4),
          child: PwIcon(
            icon,
            color: iconColor,
          ),
        ),
      ),
    );
  }
}

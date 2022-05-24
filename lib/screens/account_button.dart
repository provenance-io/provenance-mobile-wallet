import 'package:provenance_wallet/common/pw_design.dart';

class AccountButton extends StatelessWidget {
  const AccountButton({
    Key? key,
    required this.name,
    required this.desc,
    this.onPressed,
  }) : super(key: key);

  static const _interactiveStates = {
    MaterialState.pressed,
    MaterialState.hovered,
    MaterialState.focused,
  };

  final String name;
  final String desc;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: ButtonStyle(
        shape: MaterialStateProperty.resolveWith(
          (states) => _getBorder(context, states),
        ),
        backgroundColor: MaterialStateProperty.resolveWith(
            (states) => _getBackgroundColor(context, states)),
        elevation: MaterialStateProperty.all(0),
      ),
      child: Container(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            PwText(
              name,
              textAlign: TextAlign.center,
              color: PwColor.neutralNeutral,
              style: PwTextStyle.bodyBold,
            ),
            VerticalSpacer.small(),
            Text(
              desc,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.body.copyWith(
                    color: MaterialStateColor.resolveWith(
                      (states) => _getDescColor(context, states),
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getDescColor(BuildContext context, Set<MaterialState> states) {
    if (states.any(_interactiveStates.contains)) {
      return Theme.of(context).colorScheme.secondary250;
    } else {
      return Theme.of(context).colorScheme.neutral200;
    }
  }

  Color _getBackgroundColor(BuildContext context, Set<MaterialState> states) {
    if (states.any(_interactiveStates.contains)) {
      return Theme.of(context).colorScheme.secondary700;
    } else {
      return Theme.of(context).colorScheme.neutral700;
    }
  }

  OutlinedBorder _getBorder(BuildContext context, Set<MaterialState> states) {
    if (states.any(_interactiveStates.contains)) {
      return RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(
          width: 2,
          color: Theme.of(context).colorScheme.secondary400,
        ),
      );
    } else {
      return RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      );
    }
  }
}

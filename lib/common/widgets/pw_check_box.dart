import 'package:provenance_wallet/common/pw_design.dart';

class PwCheckBox extends StatelessWidget {
  const PwCheckBox({
    Key? key,
    required this.selected,
    required this.onSelect,
  }) : super(key: key);

  final ValueChanged<bool> onSelect;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: _buttonStyle(context),
      onPressed: () => onSelect(!selected),
      child: Center(
        child: PwIcon(
          PwIcons.check,
          size: 12,
          color: selected
              ? Theme.of(context).colorScheme.neutralNeutral
              : Colors.transparent,
        ),
      ),
    );
  }

  ButtonStyle _buttonStyle(BuildContext context) {
    final theme = Theme.of(context);

    return ButtonStyle(
      side: MaterialStateProperty.resolveWith((states) {
        return states.contains(MaterialState.focused)
            ? BorderSide(
                color: selected
                    ? theme.colorScheme.neutralNeutral
                    : theme.colorScheme.neutral550,
                width: 4,
              )
            : BorderSide(color: theme.colorScheme.primary550, width: 1);
      }),
      foregroundColor: MaterialStateProperty.resolveWith((states) {
        return selected ? theme.colorScheme.neutralNeutral : Colors.transparent;
      }),
      backgroundColor: MaterialStateProperty.resolveWith((states) {
        return selected ? theme.colorScheme.primary500 : Colors.transparent;
      }),
      padding: MaterialStateProperty.all(
        EdgeInsets.zero,
      ),
      minimumSize: MaterialStateProperty.all(
        Size(
          32,
          32,
        ),
      ),
    );
  }
}

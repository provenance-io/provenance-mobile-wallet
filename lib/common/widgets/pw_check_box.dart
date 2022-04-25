import 'package:provenance_blockchain_wallet/common/pw_design.dart';

class PwCheckBox extends StatefulWidget {
  const PwCheckBox({
    Key? key,
    required this.onSelect,
  }) : super(key: key);

  final ValueChanged<bool> onSelect;

  @override
  _PwCheckBoxState createState() => _PwCheckBoxState();
}

class _PwCheckBoxState extends State<PwCheckBox> {
  bool _selected = false;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: _buttonStyle(context),
      onPressed: _onTap,
      child: Center(
        child: PwIcon(
          PwIcons.check,
          //size: 8,
          color: _selected
              ? Theme.of(context).colorScheme.neutralNeutral
              : Colors.transparent,
        ),
      ),
    );
  }

  void _onTap() {
    setState(() {
      _selected = !_selected;
    });
    widget.onSelect(_selected);
  }

  ButtonStyle _buttonStyle(BuildContext context) {
    final theme = Theme.of(context);

    return ButtonStyle(
      side: MaterialStateProperty.resolveWith((states) {
        return states.contains(MaterialState.focused)
            ? BorderSide(
                color: _selected
                    ? theme.colorScheme.neutralNeutral
                    : theme.colorScheme.neutral550,
                width: 4,
              )
            : BorderSide(color: theme.colorScheme.primary550, width: 1);
      }),
      foregroundColor: MaterialStateProperty.resolveWith((states) {
        return _selected
            ? theme.colorScheme.neutralNeutral
            : Colors.transparent;
      }),
      backgroundColor: MaterialStateProperty.resolveWith((states) {
        return _selected ? theme.colorScheme.primary500 : Colors.transparent;
      }),
      minimumSize: MaterialStateProperty.all(
        Size(
          20,
          20,
        ),
      ),
    );
  }
}

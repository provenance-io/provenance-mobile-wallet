import 'package:flutter_switch/flutter_switch.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/screens/home/settings/item_label.dart';

class ToggleItem extends StatelessWidget {
  const ToggleItem({
    required this.text,
    required this.value,
    required this.onChanged,
    Key? key,
  }) : super(key: key);

  final String text;
  final bool? value;
  final void Function(bool) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      margin: EdgeInsets.symmetric(
        horizontal: Spacing.large,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ItemLabel(
            text: text,
          ),
          Expanded(
            child: Container(),
          ),
          Container(
            alignment: Alignment.centerRight,
            margin: EdgeInsets.only(
              right: Spacing.medium,
            ),
            child: value == null
                ? Container()
                : FlutterSwitch(
                    value: value!,
                    onToggle: onChanged,
                    inactiveColor: Theme.of(context).colorScheme.neutral450,
                    activeColor: Theme.of(context).colorScheme.primary550,
                    toggleColor: Theme.of(context).colorScheme.neutral800,
                    padding: 3,
                    height: 20,
                    width: 40,
                    borderRadius: Spacing.large,
                    toggleSize: 14.0,
                  ),
          ),
        ],
      ),
    );
  }
}

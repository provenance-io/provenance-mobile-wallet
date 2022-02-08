import 'package:provenance_wallet/common/pw_design.dart';

class PwDropDown extends StatefulWidget {
  PwDropDown({
    Key? key,
    required this.initialValue,
    required this.items,
  }) : super(key: key);

  final String initialValue;
  final List<String> items;

  @override
  State<PwDropDown> createState() => _PwDropDownState();
}

class _PwDropDownState extends State<PwDropDown> {
  late String dropdownValue;

  @override
  void initState() {
    dropdownValue = widget.initialValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      dropdownColor: Theme.of(context).colorScheme.globalNeutral150,
      underline: Container(),
      value: dropdownValue,
      icon: Padding(
        padding: EdgeInsets.only(left: 16),
        child: PwIcon(PwIcons.chevron),
      ),
      onChanged: (String? newValue) {
        setState(() {
          dropdownValue = newValue!;
        });
      },
      items: widget.items.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: PwText(
            value,
            color: PwColor.globalNeutral550,
            style: PwTextStyle.s,
          ),
        );
      }).toList(),
    );
  }
}

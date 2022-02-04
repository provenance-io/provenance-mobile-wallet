import 'package:provenance_wallet/common/fw_design.dart';

class FwDropDown extends StatefulWidget {
  FwDropDown({
    Key? key,
    required this.initialValue,
    required this.items,
  }) : super(key: key);

  final String initialValue;
  final List<String> items;

  @override
  State<FwDropDown> createState() => _FwDropDownState();
}

class _FwDropDownState extends State<FwDropDown> {
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
        child: FwIcon(FwIcons.chevron),
      ),
      onChanged: (String? newValue) {
        setState(() {
          dropdownValue = newValue!;
        });
      },
      items: widget.items.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: FwText(
            value,
            color: FwColor.globalNeutral550,
            style: FwTextStyle.s,
          ),
        );
      }).toList(),
    );
  }
}

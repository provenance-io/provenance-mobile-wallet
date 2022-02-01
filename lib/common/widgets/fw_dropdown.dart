import 'package:provenance_wallet/common/fw_design.dart';

class FwDropDown extends StatefulWidget {
  FwDropDown({
    Key? key,
    required this.initialValue,
    required this.items,
  }) : super(key: key);

  String initialValue;
  List<String> items;

  @override
  State<FwDropDown> createState() => _FwDropDownState();
}

class _FwDropDownState extends State<FwDropDown> {
  String dropdownValue = "";

  @override
  void initState() {
    dropdownValue = widget.initialValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: dropdownValue,
      icon: FwIcon(FwIcons.chevron),
      style: Theme.of(context).textTheme.small,
      onChanged: (String? newValue) {
        setState(() {
          dropdownValue = newValue!;
        });
      },
      items: widget.items.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}

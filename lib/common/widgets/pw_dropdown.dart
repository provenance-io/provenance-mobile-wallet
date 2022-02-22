import 'package:provenance_wallet/common/pw_design.dart';

class PwDropDown<X> extends StatefulWidget {
  PwDropDown({
    Key? key,
    required this.initialValue,
    required this.items,
    required this.builder,
    this.onValueChanged,
    this.isExpanded = false,
    this.itemHeight = kMinInteractiveDimension,
    this.dropdownColor,
  }) : super(key: key);

  final X initialValue;
  final List<X> items;
  final Widget Function(X item) builder;
  final void Function(X item)? onValueChanged;
  final bool isExpanded;
  final double? itemHeight;
  final Color? dropdownColor;

  @override
  State<PwDropDown> createState() => _PwDropDownState<X>();

  static PwDropDown<String> fromStrings({
    Key? key,
    required String initialValue,
    required List<String> items,
  })
  {
    return PwDropDown<String>(
      initialValue: initialValue,
      items: items,
      key: key,
      builder: (item) => PwText(
        item,
        color: PwColor.globalNeutral550,
        style: PwTextStyle.s,
      ),
    );
  }
}

class _PwDropDownState<X> extends State<PwDropDown<X>> {
  late X dropdownValue;

  @override
  void initState() {
    dropdownValue = widget.initialValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<X>(
      isExpanded: widget.isExpanded,
      itemHeight: widget.itemHeight,
      dropdownColor: widget.dropdownColor ?? Theme.of(context).colorScheme.globalNeutral150,
      underline: Container(),
      value: dropdownValue,
      icon: Padding(
        padding: EdgeInsets.only(left: 16),
        child: PwIcon(
          PwIcons.chevron,
          // TODO: Need some kind of neutral instead of white when dealing with colors.
          color: Theme.of(context).colorScheme.white,
        ),
      ),
      onChanged: _onChange,
      items: widget.items.map<DropdownMenuItem<X>>((X value) {
        return DropdownMenuItem<X>(
          value: value,
          child: widget.builder(value),
        );
      }).toList(),
    );
  }

  void _onChange(X? newValue) {
    setState(() {
      dropdownValue = newValue!;
    });

    if(widget.onValueChanged != null) {
      widget.onValueChanged!.call(newValue!);
    }
  }
}

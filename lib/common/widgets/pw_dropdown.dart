import 'package:provenance_wallet/common/pw_design.dart';

class PwDropDown<X> extends StatefulWidget {
  const PwDropDown({
    Key? key,
    required this.initialValue,
    required this.items,
    required this.builder,
    this.onValueChanged,
    this.isExpanded = false,
    this.autofocus = false,
    this.focusNode,
    this.itemHeight = kMinInteractiveDimension,
    this.dropdownColor,
    this.icon,
  }) : super(key: key);

  final X initialValue;
  final List<X> items;
  final Widget Function(X item) builder;
  final void Function(X item)? onValueChanged;
  final bool isExpanded;
  final bool autofocus;
  final FocusNode? focusNode;
  final double? itemHeight;
  final Color? dropdownColor;
  final Widget? icon;

  @override
  State<PwDropDown> createState() => _PwDropDownState<X>();

  static PwDropDown<String> fromStrings({
    Key? key,
    required String initialValue,
    required List<String> items,
    void Function(String item)? onValueChanged,
  }) {
    return PwDropDown<String>(
      initialValue: initialValue,
      items: items,
      key: key,
      isExpanded: true,
      onValueChanged: onValueChanged,
      builder: (item) => Row(
        children: [
          PwText(
            item,
            color: PwColor.neutralNeutral,
            style: PwTextStyle.body,
          ),
        ],
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
      autofocus: widget.autofocus,
      focusNode: widget.focusNode,
      itemHeight: widget.itemHeight,
      dropdownColor:
          widget.dropdownColor ?? Theme.of(context).colorScheme.neutral750,
      underline: Container(),
      value: dropdownValue,
      icon: widget.icon ??
          Padding(
            padding: EdgeInsets.only(left: 16),
            child: PwIcon(
              PwIcons.chevron,
              color: Theme.of(context).colorScheme.neutralNeutral,
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

    if (widget.onValueChanged != null) {
      widget.onValueChanged!.call(newValue!);
    }
  }
}

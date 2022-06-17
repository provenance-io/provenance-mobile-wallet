import 'package:provenance_wallet/common/pw_design.dart';

class PwDropDown<X> extends StatefulWidget {
  const PwDropDown({
    Key? key,
    required this.value,
    required this.items,
    required this.builder,
    required this.onValueChanged,
    this.isExpanded = false,
    this.autofocus = false,
    this.focusNode,
    this.itemHeight = kMinInteractiveDimension,
    this.dropdownColor,
  }) : super(key: key);

  final X value;
  final List<X> items;
  final Widget Function(X item) builder;
  final void Function(X item) onValueChanged;
  final bool isExpanded;
  final bool autofocus;
  final FocusNode? focusNode;
  final double? itemHeight;
  final Color? dropdownColor;

  @override
  State<PwDropDown> createState() => _PwDropDownState<X>();

  static PwDropDown<String> fromStrings({
    Key? key,
    required String value,
    required List<String> items,
    required void Function(String item) onValueChanged,
  }) {
    return PwDropDown<String>(
      value: value,
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
  late X _value;

  @override
  void initState() {
    super.initState();

    _value = widget.value;
  }

  @override
  void didUpdateWidget(covariant PwDropDown<X> oldWidget) {
    super.didUpdateWidget(oldWidget);

    _value = widget.value;
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
      value: _value,
      icon: Padding(
        padding: EdgeInsets.only(left: 16),
        child: PwIcon(
          PwIcons.chevron,
          color: Theme.of(context).colorScheme.neutralNeutral,
        ),
      ),
      onChanged: (e) => widget.onValueChanged.call(e!),
      items: widget.items.map<DropdownMenuItem<X>>((X value) {
        return DropdownMenuItem<X>(
          value: value,
          child: widget.builder(value),
        );
      }).toList(),
    );
  }
}

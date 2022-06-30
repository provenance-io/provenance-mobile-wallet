import 'dart:async';

import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/screens/home/settings/toggle_item.dart';

class FutureToggleItem extends StatefulWidget {
  const FutureToggleItem({
    required this.text,
    required this.getValue,
    required this.setValue,
    Key? key,
  }) : super(key: key);

  final String text;
  final Future<bool> Function() getValue;
  final Future Function(bool) setValue;

  @override
  _FutureToggleItemState createState() => _FutureToggleItemState();
}

class _FutureToggleItemState extends State<FutureToggleItem> {
  bool? _value;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _getValue();
  }

  @override
  Widget build(BuildContext context) {
    return ToggleItem(
      text: widget.text,
      value: _value,
      onChanged: (value) async {
        await widget.setValue(value);
        await _getValue();
      },
    );
  }

  Future _getValue() async {
    final value = await widget.getValue();
    if (value != _value) {
      setState(() {
        _value = value;
      });
    }
  }
}

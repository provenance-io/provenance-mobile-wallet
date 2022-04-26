import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/services/asset_service/asset_service.dart';

class AssetBarChartButton extends StatelessWidget {
  const AssetBarChartButton({
    Key? key,
    required this.dataValue,
    required this.onClicked,
    this.isSelected = false,
  }) : super(key: key);
  final GraphingDataValue dataValue;
  final bool isSelected;
  final VoidCallback onClicked;

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      constraints: BoxConstraints.tight(Size(30, 30)),
      shape: CircleBorder(
        side: BorderSide(
          color: isSelected
              ? Theme.of(context).colorScheme.secondary650
              : Colors.transparent,
        ),
      ),
      fillColor: isSelected
          ? Theme.of(context).colorScheme.secondary650
          : Colors.transparent,
      child: PwText(
        dataValue.name.toUpperCase()[0],
        color: isSelected ? PwColor.secondary250 : PwColor.neutralNeutral,
      ),
      onPressed: onClicked,
    );
  }
}

class AssetBarChartButtons extends StatelessWidget {
  AssetBarChartButtons({
    required this.onValueChanged,
    required GraphingDataValue initialValue,
    Key? key,
  })  : _currentValue = ValueNotifier(initialValue),
        super(key: key);

  final ValueNotifier<GraphingDataValue> _currentValue;
  final void Function(GraphingDataValue newValue) onValueChanged;

  @override
  Widget build(BuildContext context) {
    const values = GraphingDataValue.values;

    return Flexible(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: values.map((value) {
          return AssetBarChartButton(
            dataValue: value,
            onClicked: () => _onGraphingDataClicked(value),
            isSelected: value == _currentValue.value,
          );
        }).toList(),
      ),
    );
  }

  void _onGraphingDataClicked(GraphingDataValue newValue) {
    _currentValue.value = newValue;
    onValueChanged(newValue);
  }
}

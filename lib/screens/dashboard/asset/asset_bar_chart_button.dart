import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/screens/dashboard/asset/asset_chart_bloc.dart';
import 'package:provenance_wallet/services/asset_service/asset_service.dart';
import 'package:provenance_wallet/util/get.dart';

class AssetBarChartButton extends StatelessWidget {
  const AssetBarChartButton({Key? key, required this.dataValue})
      : super(key: key);
  final GraphingDataValue dataValue;

  @override
  Widget build(BuildContext context) {
    var bloc = get<AssetChartBloc>();

    return StreamBuilder<AssetChartDetails?>(
      initialData: bloc.chartDetails.value,
      stream: bloc.chartDetails,
      builder: (context, snapshot) {
        final isSelected = snapshot.data?.value == dataValue;

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
          onPressed: () {
            if (!isSelected) {
              bloc.load(value: dataValue);
            }
          },
        );
      },
    );
  }
}

class AssetBarChartButtons extends StatelessWidget {
  const AssetBarChartButtons({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: const [
          AssetBarChartButton(dataValue: GraphingDataValue.hourly),
          AssetBarChartButton(dataValue: GraphingDataValue.daily),
          AssetBarChartButton(dataValue: GraphingDataValue.weekly),
          AssetBarChartButton(dataValue: GraphingDataValue.monthly),
          AssetBarChartButton(dataValue: GraphingDataValue.yearly),
          AssetBarChartButton(dataValue: GraphingDataValue.all),
        ],
      ),
    );
  }
}

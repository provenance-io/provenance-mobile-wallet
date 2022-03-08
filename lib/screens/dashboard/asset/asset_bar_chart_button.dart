import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
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

        return PwButton(
          child: Container(
            height: 30,
            width: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? Theme.of(context).colorScheme.secondary650
                      : Colors.transparent,
                  spreadRadius: 20,
                ),
              ],
            ),
            child: Center(
              child: PwText(
                dataValue.name.toUpperCase()[0],
                color:
                    isSelected ? PwColor.secondary250 : PwColor.neutralNeutral,
              ),
            ),
          ),
          onPressed: () {
            if (!isSelected) {
              bloc.load(dataValue);
            }
          },
        );
      },
    );
  }
}

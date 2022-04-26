import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/screens/home/asset/asset_chart_bloc.dart';
import 'package:provenance_wallet/util/extensions/double_extensions.dart';
import 'package:provenance_wallet/util/get.dart';

class AssetPercentageChanged extends StatelessWidget {
  const AssetPercentageChanged({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = get<AssetChartBloc>();

    return StreamBuilder<AssetChartDetails?>(
      initialData: bloc.chartDetails.value,
      stream: bloc.chartDetails,
      builder: (context, snapshot) {
        final list = snapshot.data?.graphItemList;
        if (list == null || list.length < 2) {
          return PwText("");
        } else {
          var last = list.last;
          var penultimate = list[list.length - 2];
          final displayPrice = last.price - penultimate.price;
          final percentageChanged = displayPrice / penultimate.price * 100;
          final arrow = percentageChanged == 0
              ? ""
              : percentageChanged < 0
                  ? '↓ '
                  : '↑ ';

          return PwText(
            "$arrow${displayPrice.toCurrency()} (${percentageChanged.toStringAsFixed(3)}%)",
          );
        }
      },
    );
  }
}

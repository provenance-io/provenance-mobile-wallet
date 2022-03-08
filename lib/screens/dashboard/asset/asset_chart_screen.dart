import 'package:flutter_svg/flutter_svg.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/screens/dashboard/asset/asset_bar_chart.dart';
import 'package:provenance_wallet/screens/dashboard/asset/asset_bar_chart_button.dart';
import 'package:provenance_wallet/screens/dashboard/asset/asset_chart_bloc.dart';
import 'package:provenance_wallet/services/asset_service/asset_service.dart';
import 'package:provenance_wallet/services/models/asset.dart';
import 'package:provenance_wallet/util/assets.dart';
import 'package:provenance_wallet/util/get.dart';

class AssetChartScreen extends StatefulWidget {
  const AssetChartScreen({
    Key? key,
    required this.asset,
    required this.dataValue,
  }) : super(key: key);

  final Asset asset;
  final GraphingDataValue dataValue;

  @override
  _AssetChartScreenState createState() => _AssetChartScreenState();
}

class _AssetChartScreenState extends State<AssetChartScreen> {
  late AssetChartBloc _bloc;

  @override
  void initState() {
    _bloc = AssetChartBloc(widget.asset);

    get.registerSingleton<AssetChartBloc>(_bloc);

    _bloc.load(widget.dataValue);

    super.initState();
  }

  @override
  void dispose() {
    get.unregister<AssetChartBloc>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AssetPaths.images.background),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          flexibleSpace: Container(
            color: Colors.transparent,
          ),
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          centerTitle: true,
          title: Column(
            children: [
              SvgPicture.asset(
                widget.asset.image,
                width: 30,
                height: 30,
              ),
              VerticalSpacer.small(),
              PwText(
                widget.asset.display.toUpperCase(),
                style: PwTextStyle.subhead,
              ),
            ],
          ),
          leading: Padding(
            padding: EdgeInsets.only(left: 21),
            child: IconButton(
              icon: PwIcon(
                PwIcons.back,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ),
        body: Container(
          padding: EdgeInsets.symmetric(
            horizontal: Spacing.xLarge,
          ),
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 7),
                    child: PwText(
                      '\$',
                      style: PwTextStyle.h2,
                      color: PwColor.neutralNeutral,
                    ),
                  ),
                  PwText(
                    widget.asset.usdPrice.toStringAsFixed(3),
                    style: PwTextStyle.h1,
                    color: PwColor.neutralNeutral,
                  ),
                ],
              ),
              // TODO: This is demo text, to be replaced by a service.
              PwText("↑ \$0.008 (0.10%)"),
              AssetBarChart(),
              VerticalSpacer.medium(),
              Flexible(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: const [
                    AssetBarChartButton(dataValue: GraphingDataValue.hourly),
                    AssetBarChartButton(dataValue: GraphingDataValue.daily),
                    AssetBarChartButton(dataValue: GraphingDataValue.weekly),
                    AssetBarChartButton(dataValue: GraphingDataValue.monthly),
                    AssetBarChartButton(dataValue: GraphingDataValue.yearly),
                    AssetBarChartButton(dataValue: GraphingDataValue.allTime),
                  ],
                ),
              ),
              VerticalSpacer.xxLarge(),
              Row(
                children: const [
                  PwText(
                    "Statistics",
                    style: PwTextStyle.headline4,
                  ),
                ],
              ),
              StreamBuilder<AssetChartDetails?>(
                initialData: _bloc.chartDetails.value,
                stream: _bloc.chartDetails,
                builder: (context, snapshot) {
                  final stats = snapshot.data?.assetStatistics;

                  return Container();
                },
              ),
              VerticalSpacer.medium(),
            ],
          ),
        ),
      ),
    );
  }
}

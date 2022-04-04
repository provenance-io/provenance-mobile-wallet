import 'package:flutter_svg/flutter_svg.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/screens/dashboard/asset/asset_bar_chart.dart';
import 'package:provenance_wallet/screens/dashboard/asset/asset_bar_chart_button.dart';
import 'package:provenance_wallet/screens/dashboard/asset/asset_chart_bloc.dart';
import 'package:provenance_wallet/screens/dashboard/asset/asset_chart_recent_transactions.dart';
import 'package:provenance_wallet/screens/dashboard/asset/asset_chart_statistics.dart';
import 'package:provenance_wallet/screens/dashboard/asset/asset_percentage_changed.dart';
import 'package:provenance_wallet/screens/dashboard/asset/dashboard_asset_bloc.dart';
import 'package:provenance_wallet/services/models/asset.dart';
import 'package:provenance_wallet/util/assets.dart';
import 'package:provenance_wallet/util/get.dart';

class AssetChartScreen extends StatefulWidget {
  const AssetChartScreen(
    this.coin,
    this.asset, {
    Key? key,
  }) : super(key: key);

  final Coin coin;
  final Asset asset;

  @override
  _AssetChartScreenState createState() => _AssetChartScreenState();
}

class _AssetChartScreenState extends State<AssetChartScreen> {
  late AssetChartBloc _bloc;

  @override
  void initState() {
    if (!get.isRegistered<AssetChartBloc>()) {
      final bloc = AssetChartBloc(widget.coin, widget.asset);
      get.registerSingleton(bloc);
      _bloc = bloc..load();
    } else {
      _bloc = get<AssetChartBloc>();
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AssetChartDetails?>(
      initialData: _bloc.chartDetails.value,
      stream: _bloc.chartDetails,
      builder: (context, snapshot) {
        final details = snapshot.data;
        if (null == details) {
          return Container();
        }

        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(AssetPaths.images.background),
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
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
                    details.asset.image,
                    width: 30,
                    height: 30,
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
                    get.unregister<AssetChartBloc>();
                    get<DashboardAssetBloc>().closeAsset();
                  },
                ),
              ),
            ),
            body: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Spacing.xLarge,
                ),
                color: Colors.transparent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PwText(
                      details.asset.display.toUpperCase(),
                      style: PwTextStyle.subhead,
                    ),
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
                          details.asset.formattedUsdPrice,
                          style: PwTextStyle.h1,
                          color: PwColor.neutralNeutral,
                        ),
                      ],
                    ),
                    AssetPercentageChanged(),
                    AssetBarChart(),
                    VerticalSpacer.medium(),
                    AssetBarChartButtons(),
                    VerticalSpacer.xxLarge(),
                    AssetChartStatistics(),
                    VerticalSpacer.xxLarge(),
                    AssetChartRecentTransactions(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

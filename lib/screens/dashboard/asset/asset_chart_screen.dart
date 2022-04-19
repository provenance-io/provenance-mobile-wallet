import 'dart:math';

import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_autosizing_text.dart';
import 'package:provenance_wallet/screens/dashboard/asset/asset_bar_chart.dart';
import 'package:provenance_wallet/screens/dashboard/asset/asset_bar_chart_button.dart';
import 'package:provenance_wallet/screens/dashboard/asset/asset_chart_bloc.dart';
import 'package:provenance_wallet/screens/dashboard/asset/asset_chart_recent_transactions.dart';
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
      _bloc = bloc..load(startDate: DateTime.now(), endDate: DateTime.now());
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
              image: AssetImage(Assets.images.background),
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
                  Assets.getSvgPictureFrom(
                    denom: details.asset.denom,
                    size: 30,
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    PwText(
                      details.asset.display.toUpperCase(),
                      style: PwTextStyle.subhead,
                      textAlign: TextAlign.center,
                    ),
                    PwAutoSizingText(
                      details.asset.formattedUsdPrice,
                      height: 45,
                      style: PwTextStyle.h1,
                      color: PwColor.neutralNeutral,
                    ),
                    AssetBarChart(snapshot.data!.value),
                    VerticalSpacer.small(),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return Container(
                          alignment: Alignment.center,
                          width: min(constraints.maxWidth, 75),
                          child: AssetBarChartButtons(
                            snapshot.data!.startDate,
                            snapshot.data!.endDate,
                            (startDate, endDate) {
                              _bloc.load(
                                startDate: startDate,
                                endDate: endDate,
                              );
                            },
                          ),
                        );
                      },
                    ),
                    VerticalSpacer.xxLarge(),
                    VerticalSpacer.xxLarge(),
                    AssetChartRecentTransactions(asset: widget.asset),
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

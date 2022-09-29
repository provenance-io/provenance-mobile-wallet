import 'package:intl/intl.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_autosizing_text.dart';
import 'package:provenance_wallet/screens/home/asset/asset_bar_chart.dart';
import 'package:provenance_wallet/screens/home/asset/asset_bar_chart_button.dart';
import 'package:provenance_wallet/screens/home/asset/asset_chart_bloc.dart';
import 'package:provenance_wallet/screens/home/asset/asset_chart_recent_transactions.dart';
import 'package:provenance_wallet/screens/home/asset/dashboard_tab_bloc.dart';
import 'package:provenance_wallet/screens/home/asset/price_change_indicator.dart';
import 'package:provenance_wallet/services/asset_client/asset_client.dart';
import 'package:provenance_wallet/util/assets.dart';
import 'package:provider/provider.dart';

class AssetChartScreen extends StatefulWidget {
  const AssetChartScreen({
    Key? key,
  }) : super(key: key);

  @override
  _AssetChartScreenState createState() => _AssetChartScreenState();
}

class _AssetChartScreenState extends State<AssetChartScreen> {
  final ValueNotifier<AssetChartPointData?> changeNotifier =
      ValueNotifier(null);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<AssetChartBloc>(context, listen: false);
    final mediaQuery = MediaQuery.of(context);
    final isTallScreen = mediaQuery.size.height > 600;
    final priceHeight = (isTallScreen) ? 45.0 : 35.0;

    return StreamBuilder<AssetChartDetails?>(
      initialData: bloc.chartDetails.value,
      stream: bloc.chartDetails,
      builder: (context, snapshot) {
        final details = snapshot.data;
        if (null == details) {
          return Container();
        }

        final colorScheme =
            Theme.of(context).colorScheme as ProvenanceColorScheme;

        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(Assets.imagePaths.background),
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
              leading: IconButton(
                icon: PwIcon(
                  PwIcons.back,
                ),
                onPressed: () {
                  Provider.of<DashboardTabBloc>(context, listen: false)
                      .closeAsset();
                },
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
                    ValueListenableBuilder<AssetChartPointData?>(
                      valueListenable: changeNotifier,
                      builder: (
                        context,
                        value,
                        chil,
                      ) {
                        final formatter = NumberFormat.simpleCurrency();
                        final priceString = (value != null)
                            ? formatter.format(value.price)
                            : details.asset.formattedUsdPrice;

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            PwAutoSizingText(
                              priceString,
                              height: priceHeight,
                              style: PwTextStyle.h1,
                              color: PwColor.neutralNeutral,
                            ),
                            SizedBox(
                              child: PriceChangeIndicator(value),
                              height: 45,
                            ),
                          ],
                        );
                      },
                    ),
                    AssetBarChart(
                      snapshot.data!.value,
                      isCompact: !isTallScreen,
                      graphColor: colorScheme.graphLine,
                      graphFillColor: colorScheme.graphFill,
                      onTouchPointChanged: (touchPoint) {
                        changeNotifier.value = touchPoint;
                      },
                    ),
                    VerticalSpacer.small(),
                    AssetBarChartButtons(
                      initialValue: details.value,
                      onValueChanged: (GraphingDataValue newValue) {
                        bloc.load(
                          value: newValue,
                        );
                      },
                    ),
                    (isTallScreen)
                        ? VerticalSpacer.xxLarge()
                        : VerticalSpacer.medium(),
                    (isTallScreen)
                        ? VerticalSpacer.xxLarge()
                        : VerticalSpacer.medium(),
                    AssetChartRecentTransactions(asset: details.asset),
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

import 'package:flutter_svg/flutter_svg.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/dashboard/asset/asset_bar_chart.dart';
import 'package:provenance_wallet/screens/dashboard/dashboard_bloc.dart';
import 'package:provenance_wallet/services/models/asset.dart';
import 'package:provenance_wallet/util/assets.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class AssetChartScreen extends StatefulWidget {
  const AssetChartScreen({
    Key? key,
    required this.asset,
  }) : super(key: key);

  final Asset asset;

  @override
  _AssetChartScreenState createState() => _AssetChartScreenState();
}

class _AssetChartScreenState extends State<AssetChartScreen> {
  @override
  Widget build(BuildContext context) {
    final bloc = get<DashboardBloc>();

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(AssetPaths.images.background),
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        centerTitle: true,
        title: SvgPicture.asset(
          widget.asset.image,
          width: 30,
          height: 30,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AssetPaths.images.background),
            fit: BoxFit.cover,
          ),
        ),
        padding: EdgeInsets.only(
          top: Spacing.xxLarge,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AssetBarChart(),
            VerticalSpacer.xxLarge(),
            StreamBuilder<List<Asset>?>(
              initialData: bloc.assetList.value,
              stream: bloc.assetList,
              builder: (context, snapshot) {
                final assets = snapshot.data ?? [];

                return assets.isEmpty
                    ? Container()
                    : Padding(
                        padding: EdgeInsets.only(
                          left: Spacing.xxLarge,
                          right: Spacing.xxLarge,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: const [
                            PwText(
                              Strings.myAssets,
                              style: PwTextStyle.title,
                            ),
                          ],
                        ),
                      );
              },
            ),
            VerticalSpacer.medium(),
            Expanded(
              child: StreamBuilder<List<Asset>?>(
                initialData: bloc.assetList.value,
                stream: bloc.assetList,
                builder: (context, snapshot) {
                  final assets = snapshot.data ?? [];

                  return ListView.separated(
                    padding: EdgeInsets.only(
                      left: Spacing.xxLarge,
                      right: Spacing.xxLarge,
                    ),
                    itemBuilder: (context, index) {
                      final item = assets[index];

                      return Column(
                        children: [
                          if (index == 0) PwListDivider(),
                          GestureDetector(
                            onTap: () {
                              // TODO: Load Asset
                            },
                            child: Padding(
                              padding: EdgeInsets.zero,
                              child: Container(
                                padding: EdgeInsets.only(
                                  right: 16,
                                  left: 16,
                                  top: Spacing.xLarge,
                                  bottom: Spacing.xLarge,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 40,
                                      height: 40,
                                      child: SvgPicture.asset(
                                        item.image,
                                        width: 40,
                                        height: 40,
                                      ),
                                    ),
                                    HorizontalSpacer.medium(),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        PwText(
                                          item.display,
                                          style: PwTextStyle.bodyBold,
                                        ),
                                        VerticalSpacer.xSmall(),
                                        PwText(
                                          item.formattedAmount,
                                          color: PwColor.neutral200,
                                          style: PwTextStyle.footnote,
                                        ),
                                      ],
                                    ),
                                    Expanded(child: Container()),
                                    PwIcon(
                                      PwIcons.caret,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .neutralNeutral,
                                      size: 12.0,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                    separatorBuilder: (context, index) {
                      return PwListDivider();
                    },
                    itemCount: assets.length,
                    shrinkWrap: true,
                    physics: AlwaysScrollableScrollPhysics(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

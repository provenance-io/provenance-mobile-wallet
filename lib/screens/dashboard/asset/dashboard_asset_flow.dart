import 'package:provenance_wallet/common/flow_base.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/screens/dashboard/asset/asset_chart_screen.dart';
import 'package:provenance_wallet/screens/dashboard/asset/dashboard_asset_bloc.dart';
import 'package:provenance_wallet/screens/dashboard/asset/view_all_transactions_screen.dart';
import 'package:provenance_wallet/screens/dashboard/landing/dashboard_landing_tab.dart';
import 'package:provenance_wallet/util/get.dart';

import 'asset_details.dart';

class DashboardAssetFlow extends FlowBase {
  const DashboardAssetFlow({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => DashboardAssetFlowState();
}

class DashboardAssetFlowState extends FlowBaseState<DashboardAssetFlow> {
  late DashboardAssetBloc _bloc;

  @override
  void initState() {
    super.initState();
    if (!get.isRegistered<DashboardAssetBloc>()) {
      get.registerSingleton<DashboardAssetBloc>(
        DashboardAssetBloc(),
      );
    }
    _bloc = get<DashboardAssetBloc>();
  }

  @override
  Widget createStartPage() => StreamBuilder<AssetDetails?>(
        initialData: _bloc.assetDetails.value,
        stream: _bloc.assetDetails,
        builder: (context, snapshot) {
          final details = snapshot.data;
          if (null == details) {
            return DashboardLandingTab();
          }

          return details.showAllTransactions
              ? ViewAllTransactionsScreen()
              : AssetChartScreen(details.coin, details.asset);
        },
      );
}

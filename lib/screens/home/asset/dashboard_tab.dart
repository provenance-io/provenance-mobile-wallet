import 'package:provenance_wallet/common/flow_base.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/screens/home/asset/asset_chart_screen.dart';
import 'package:provenance_wallet/screens/home/asset/dashboard_tab_bloc.dart';
import 'package:provenance_wallet/screens/home/asset/view_all_transactions_screen.dart';
import 'package:provenance_wallet/screens/home/dashboard/dashboard.dart';
import 'package:provenance_wallet/util/get.dart';

import 'asset_details.dart';

class DashboardTab extends FlowBase {
  const DashboardTab({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => DashboardTabState();
}

class DashboardTabState extends FlowBaseState<DashboardTab> {
  late DashboardTabBloc _bloc;

  @override
  void initState() {
    super.initState();
    if (!get.isRegistered<DashboardTabBloc>()) {
      get.registerSingleton<DashboardTabBloc>(
        DashboardTabBloc(),
      );
    }
    _bloc = get<DashboardTabBloc>();
  }

  @override
  Widget createStartPage() => StreamBuilder<AssetDetails?>(
        initialData: _bloc.assetDetails.value,
        stream: _bloc.assetDetails,
        builder: (context, snapshot) {
          final details = snapshot.data;
          if (null == details) {
            return Dashboard();
          }

          return details.showAllTransactions
              ? ViewAllTransactionsScreen()
              : AssetChartScreen(details.coin, details.asset);
        },
      );
}

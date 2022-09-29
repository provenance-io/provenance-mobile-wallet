import 'package:provenance_wallet/common/flow_base.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/screens/home/asset/asset_chart_bloc.dart';
import 'package:provenance_wallet/screens/home/asset/asset_chart_screen.dart';
import 'package:provenance_wallet/screens/home/asset/dashboard_tab_bloc.dart';
import 'package:provenance_wallet/screens/home/asset/view_all_transactions_screen.dart';
import 'package:provenance_wallet/screens/home/dashboard/dashboard.dart';
import 'package:provider/provider.dart';

import 'asset_details.dart';

class DashboardTab extends FlowBase {
  const DashboardTab({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => DashboardTabState();
}

class DashboardTabState extends State<DashboardTab> {
  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<DashboardTabBloc>(context, listen: false);
    return StreamBuilder<AssetDetails?>(
      initialData: bloc.assetDetails.value,
      stream: bloc.assetDetails,
      builder: (context, snapshot) {
        final details = snapshot.data;
        if (null == details) {
          return Dashboard();
        }

        return details.showAllTransactions
            ? ViewAllTransactionsScreen()
            : Provider<AssetChartBloc>(
                lazy: true,
                create: (context) {
                  final bloc = AssetChartBloc(details.coin, details.asset)
                    ..load();
                  return bloc;
                },
                dispose: (_, bloc) {
                  bloc.onDispose();
                },
                child: AssetChartScreen());
      },
    );
  }
}

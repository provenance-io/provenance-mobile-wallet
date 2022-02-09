import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/network/models/asset_response.dart';
import 'package:provenance_wallet/screens/dashboard/landing/wallet_connect_no_assets.dart';
import 'package:provenance_wallet/screens/dashboard/landing/wallet_connect_with_assets.dart';
import 'package:provenance_wallet/screens/dashboard/landing/wallet_portfolio.dart';

class DashboardLanding extends StatefulWidget {
  DashboardLanding({
    Key? key,
    required this.walletKey,
  }) : super(key: key);

  // FIXME: State Management
  final GlobalKey<WalletPortfolioState> walletKey;

  @override
  State<StatefulWidget> createState() => DashboardLandingState(walletKey);
}

class DashboardLandingState extends State<DashboardLanding> {
  DashboardLandingState(this.walletKey);
  List<AssetResponse> _assets = [];
  GlobalKey<WalletPortfolioState> walletKey;

  void updateAssets(List<AssetResponse> assets) {
    setState(() {
      _assets = assets;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.white,
      padding: EdgeInsets.only(top: 40),
      child: WalletConnectSection(),
    );
  }
}

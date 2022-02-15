import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/screens/dashboard/landing/wallet_connect_section.dart';

class DashboardLanding extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 40),
      child: WalletConnectSection(),
    );
  }
}

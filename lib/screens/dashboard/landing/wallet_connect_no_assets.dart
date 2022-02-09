import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/screens/dashboard/landing/reset_button.dart';

import 'wallet_portfolio.dart';

class WalletConnectNoAssets extends StatelessWidget {
  WalletConnectNoAssets({
    Key? key,
    required this.walletKey,
  }) : super(key: key);

  // FIXME: State Management
  final GlobalKey<WalletPortfolioState> walletKey;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        WalletPortfolio(
          key: walletKey,
        ),
        VerticalSpacer.medium(),
        ResetButton(),
        VerticalSpacer.large(),
      ],
    );
  }
}

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/screens/landing/landing.dart';
import 'package:provenance_wallet/services/wallet_service.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

// TODO: Remove me? If this is just for development, that is.
class ResetButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: PwButton(
        child: PwText(
          Strings.resetWallet,
        ),
        onPressed: () async {
          final walletService = get<WalletService>();
          await walletService.currentWalletConnect?.disconnectSession();
          await walletService.resetWallets();
          FlutterSecureStorage storage = FlutterSecureStorage();
          await storage.deleteAll();

          Navigator.of(context).popUntil((route) => true);
          // Pretty sure that this is creating an additional view on the stack when one already exists.
          // If this is just for development no change is needed.
          Navigator.push(context, Landing().route());
        },
      ),
    );
  }
}

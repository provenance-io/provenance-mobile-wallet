import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:prov_wallet_flutter/prov_wallet_flutter.dart';
import 'package:provenance_wallet/common/fw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/screens/landing/landing.dart';
import 'package:provenance_wallet/util/strings.dart';

// TODO: Remove me? If this is just for development, that is.
class ResetButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: FwButton(
        child: FwText(
          Strings.resetWallet,
        ),
        onPressed: () async {
          await ProvWalletFlutter.disconnectWallet();
          await ProvWalletFlutter.resetWallet();
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

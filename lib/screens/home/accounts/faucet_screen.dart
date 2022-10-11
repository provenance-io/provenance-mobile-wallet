import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/modal_loading.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/services/asset_client/asset_client.dart';
import 'package:provenance_wallet/util/get.dart';

class FaucetScreen extends StatefulWidget {
  const FaucetScreen({
    Key? key,
    required this.address,
    required this.coin,
  }) : super(key: key);

  final String address;
  final Coin coin;

  @override
  State<StatefulWidget> createState() => FaucetScreenState();

  static final keyAddHashButton = ValueKey('$FaucetScreen.add_hash_button');
}

class FaucetScreenState extends State<FaucetScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PwAppBar(
        title: "Faucet",
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PwText(
            "PROVENANCE BLOCKCHAIN FAUCET",
            style: PwTextStyle.display1,
          ),
          PwButton(
            key: FaucetScreen.keyAddHashButton,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(
                  IconData(0xef55, fontFamily: 'MaterialIcons'),
                ),
                PwText("Get HASH"),
              ],
            ),
            onPressed: () async {
              _onLoading(context, true);
              await get<AssetClient>().getHash(widget.coin, widget.address);
              _onLoading(context, false);
            },
          ),
        ],
      ),
    );
  }

  void _onLoading(BuildContext context, bool loading) {
    if (loading) {
      ModalLoadingRoute.showLoading(context);
    } else {
      ModalLoadingRoute.dismiss(context);
    }
  }
}

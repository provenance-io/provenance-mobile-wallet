import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/modal_loading.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/services/asset_client/asset_client.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class FaucetScreen extends StatefulWidget {
  const FaucetScreen({
    Key? key,
    required this.address,
    required this.coin,
    required this.onHashAdd,
  }) : super(key: key);

  final String address;
  final Coin coin;
  final Future<void> Function() onHashAdd;

  @override
  State<StatefulWidget> createState() => FaucetScreenState();

  static final keyAddHashButton = ValueKey('$FaucetScreen.add_hash_button');
}

class FaucetScreenState extends State<FaucetScreen> {
  bool _didGetHash = false;
  bool _didError = false;
  String? _message;

  @override
  Widget build(BuildContext context) {
    final strings = Strings.of(context);
    return Scaffold(
      appBar: PwAppBar(
        title: strings.faucetScreenAppBarTitle,
        leadingIconOnPress: () {
          if (_didGetHash) {
            widget.onHashAdd();
          }
          Navigator.of(context).pop();
        },
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: Spacing.large),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            VerticalSpacer.large(),
            PwText(
              strings.faucetScreenTitle,
              style: PwTextStyle.headline1,
              textAlign: TextAlign.center,
            ),
            if (_message != null) VerticalSpacer.large(),
            if (_message != null)
              PwText(
                _message ?? "",
                color: _didError ? PwColor.error : PwColor.positive,
              ),
            VerticalSpacer.large(),
            PwButton(
              key: FaucetScreen.keyAddHashButton,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    const IconData(0xef55, fontFamily: 'MaterialIcons'),
                  ),
                  HorizontalSpacer.small(),
                  PwText(strings.faucetScreenButtonTitle),
                ],
              ),
              onPressed: () async {
                setState(() {
                  _didGetHash = true;
                  _message = null;
                  _didError = false;
                });
                _onLoading(context, true);
                try {
                  await get<AssetClient>().getHash(widget.coin, widget.address);
                  setState(() {
                    _message = strings.faucetScreenHashAddSuccess;
                  });
                } catch (e) {
                  setState(() {
                    _message = e.toString();
                    _didError = true;
                  });
                } finally {
                  _onLoading(context, false);
                }
              },
            ),
          ],
        ),
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

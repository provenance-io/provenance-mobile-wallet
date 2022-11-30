import 'package:provenance_dart/wallet_connect.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_text_form_field.dart';
import 'package:provenance_wallet/screens/home/dashboard/wallet_connect_button.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/wallet_connect_service/wallet_connect_service.dart';
import 'package:provenance_wallet/util/deep_link_util.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/link_util.dart';
import 'package:provenance_wallet/util/strings.dart';

class WalletConnectItem extends StatefulWidget {
  const WalletConnectItem({Key? key}) : super(key: key);

  @override
  State<WalletConnectItem> createState() => _WalletConnectItemState();
}

class _WalletConnectItemState extends State<WalletConnectItem> {
  final _focusNode = FocusNode();
  final _textController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(
        Spacing.large,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PwText(
            Strings.of(context).profileDeveloperConnectLabel,
          ),
          VerticalSpacer.small(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                width: 50,
                height: 50,
                child: WalletConnectButton(),
              ),
              HorizontalSpacer.large(),
              Expanded(
                child: PwTextFormField(
                  hint: Strings.of(context).profileDeveloperConnectHint,
                  controller: _textController,
                ),
              ),
            ],
          ),
          if (_error != null) ...[
            Container(
              margin: EdgeInsets.only(
                left: Spacing.large,
                top: Spacing.small,
              ),
              child: PwText(
                _error!,
                color: PwColor.error,
                style: PwTextStyle.bodySmall,
              ),
            ),
          ],
          VerticalSpacer.large(),
          PwTextButton.primaryAction(
            context: context,
            text: 'Go',
            onPressed: _onSubmitted,
          ),
        ],
      ),
    );
  }

  Future<void> _onSubmitted() async {
    final value = _textController.text;
    if (value.isEmpty) {
      return;
    }

    String? error = Strings.of(context).profileDeveloperConnectInvalidAddress;

    WalletConnectAddress? address = WalletConnectAddress.create(value);
    if (address == null) {
      final decoded = Uri.decodeComponent(value);
      address = WalletConnectAddress.create(decoded);
    }
    if (address == null) {
      final redirected = await tryFollowRedirect(value);
      if (redirected != null) {
        final uri = Uri.parse(redirected);
        address = getWalletConnectAddress(uri);
      }
    }

    if (address != null) {
      error = null;

      final bloc = get<WalletConnectService>();
      final accountId = get<AccountService>().events.selected.value?.id;
      if (accountId != null) {
        bloc.connectSession(accountId, address.raw);
      }
    }

    setState(() {
      _error = error;
    });
  }
}

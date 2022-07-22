import 'package:provenance_dart/wallet_connect.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_text_form_field.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/wallet_connect_service/wallet_connect_service.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class WalletConnectItem extends StatefulWidget {
  const WalletConnectItem({Key? key}) : super(key: key);

  @override
  State<WalletConnectItem> createState() => _WalletConnectItemState();
}

class _WalletConnectItemState extends State<WalletConnectItem> {
  final _focusNode = FocusNode();
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: Spacing.xxLarge,
        vertical: Spacing.large,
      ),
      child: PwTextFormField(
        label: Strings.of(context).profileDeveloperConnectLabel,
        validator: _validate,
        onFieldSubmitted: _onSubmitted,
      ),
    );
  }

  String? _validate(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    if (WalletConnectAddress.create(value) == null) {
      return Strings.of(context).profileDeveloperConnectInvalidAddress;
    }

    return null;
  }

  String? _onSubmitted(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    final error = _validate(value);
    if (error == null) {
      final bloc = get<WalletConnectService>();
      final accountId = get<AccountService>().events.selected.value?.id;
      if (accountId != null) {
        bloc.connectSession(accountId, value);
      }
    }

    return null;
  }
}

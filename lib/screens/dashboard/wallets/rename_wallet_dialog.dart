import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/common/widgets/pw_text_form_field.dart';
import 'package:provenance_wallet/util/strings.dart';

class RenameWalletDialog extends StatelessWidget {
  RenameWalletDialog({@required this.currentName, Key? key}) : super(key: key) {
    _nameController.text = currentName ?? '';
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  final String? currentName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PwAppBar(
        title: Strings.renameWallet,
        leadingIcon: PwIcons.close,
        leadingIconOnPress: () {
          Navigator.of(context).pop(null);
        },
      ),
      body: Form(
        key: _formKey,
        child: Container(
          color: Theme.of(context).colorScheme.neutral750,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(
                  Spacing.xxLarge,
                ),
                child: PwText(
                  Strings.renameWalletDescription,
                  style: PwTextStyle.body,
                  textAlign: TextAlign.center,
                  color: PwColor.neutralNeutral,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: Spacing.xxLarge,
                  right: Spacing.xxLarge,
                  bottom: Spacing.small,
                ),
                child: PwTextFormField(
                  label: Strings.accountName,
                  autofocus: true,
                  validator: (value) {
                    return value == null || value.isEmpty
                        ? Strings.required
                        : null;
                  },
                  controller: _nameController,
                ),
              ),
              Expanded(child: Container()),
              Padding(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: PwButton(
                  child: PwText(
                    Strings.confirm,
                    style: PwTextStyle.mBold,
                    color: PwColor.neutralNeutral,
                  ),
                  onPressed: () {
                    if (_formKey.currentState?.validate() == true) {
                      if (_nameController.text.trim() == currentName) {
                        Navigator.of(context).pop(null);
                      } else {
                        Navigator.of(context).pop(_nameController.text.trim());
                      }
                    }
                  },
                ),
              ),
              VerticalSpacer.large(),
            ],
          ),
        ),
      ),
    );
  }
}

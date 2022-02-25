import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_text_form_field.dart';
import 'package:provenance_wallet/util/strings.dart';

class RenameWalletDialog extends StatelessWidget {
  RenameWalletDialog({@required this.currentName, Key? key}) : super(key: key) {
    _nameController.text = currentName ?? '';
  }

  final GlobalKey<FormState> _formKey = GlobalKey();
  final TextEditingController _nameController = TextEditingController();

  final String? currentName;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).colorScheme.neutral700,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(Spacing.medium),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const VerticalSpacer.large(),
              PwText(
                Strings.walletRename,
                style: PwTextStyle.subhead,
              ),
              const VerticalSpacer.medium(),
              Padding(
                padding: const EdgeInsets.only(
                  top: Spacing.medium,
                  left: Spacing.medium,
                  right: Spacing.medium,
                ),
                child: PwTextFormField(
                  label: Strings.walletName,
                  controller: _nameController,
                  autofocus: true,
                  validator: (value) {
                    return ((value?.isEmpty ?? true) ? Strings.required : null);
                  },
                ),
              ),
              const VerticalSpacer.xxLarge(),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Spacing.large,
                ),
                child: PwPrimaryButton.fromString(
                  text: Strings.confirm,
                  onPressed: () async {
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
              const VerticalSpacer.small(),
              PwTextButton(
                child: PwText(Strings.cancel),
                onPressed: () => Navigator.of(context).pop(null),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

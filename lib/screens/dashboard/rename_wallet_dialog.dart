import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(Spacing.medium),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const VerticalSpacer.xxLarge(),
              Text(
                Strings.walletRename,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headline4!
                    .copyWith(color: Theme.of(context).colorScheme.black),
              ),
              const VerticalSpacer.medium(),
              Padding(
                padding: const EdgeInsets.only(
                  top: Spacing.medium,
                  left: Spacing.medium,
                  right: Spacing.medium,
                ),
                child: _TextFormField(
                  label: Strings.walletName,
                  controller: _nameController,
                  validator: (value) {
                    return ((value?.isEmpty ?? true) ? Strings.required : null);
                  },
                ),
              ),
              const VerticalSpacer.xxLarge(),
              PwPrimaryButton.fromString(
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

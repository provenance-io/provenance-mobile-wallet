import 'package:flutter_tech_wallet/common/fw_design.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tech_wallet/common/widgets/button.dart';
import 'package:flutter_tech_wallet/util/strings.dart';

class RenameWalletDialog extends StatelessWidget {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final String? currentName;
  final TextEditingController _nameController = TextEditingController();

  RenameWalletDialog({@required this.currentName, Key? key}) : super(key: key) {
    _nameController.text = currentName ?? '';
  }

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
                Text(Strings.walletRename,
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .headline4!
                        .copyWith(color: Theme.of(context).colorScheme.black)),
                const VerticalSpacer.medium(),
                Padding(
                    padding: const EdgeInsets.only(
                        top: Spacing.medium,
                        left: Spacing.medium,
                        right: Spacing.medium),
                    child: _TextFormField(
                      label: Strings.walletName,
                      controller: _nameController,
                      validator: (value) {
                        return ((value?.isEmpty ?? true)
                            ? Strings.required
                            : null);
                      },
                    )),
                const VerticalSpacer.xxLarge(),
                FwPrimaryButton(
                  child: FwText(Strings.confirm),
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
                FwTextButton(
                  child: FwText(Strings.cancel),
                  onPressed: () => Navigator.of(context).pop(null),
                )
              ],
            ),
          ),
        ));
  }
}

class _TextFormField extends StatelessWidget {
  const _TextFormField({Key? key,
    required this.label,
    this.keyboardType,
    this.onChanged,
    this.validator,
    this.controller})
      : super(key: key);

  final String label;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FwText(label),
        const VerticalSpacer.small(),
        TextFormField(
          keyboardType: keyboardType,
          autocorrect: false,
          controller: controller,
          onChanged: onChanged,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: validator,
          decoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: theme.colorScheme.midGrey),
            ),
          ),
        ),
      ],
    );
  }
}
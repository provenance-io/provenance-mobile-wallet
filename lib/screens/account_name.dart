import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provenance_wallet/common/enum/wallet_add_import_type.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/pw_theme.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/screens/create_passphrase_screen.dart';
import 'package:provenance_wallet/screens/recover_account_screen.dart';
import 'package:provenance_wallet/util/strings.dart';

class AccountName extends HookWidget {
  AccountName(
    this.flowType, {
    this.words,
    this.currentStep,
    this.numberOfSteps,
  });

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final List<String>? words;
  final int? currentStep;
  final int? numberOfSteps;
  final WalletAddImportType flowType;

  @override
  Widget build(BuildContext context) {
    final accountNameProvider = useTextEditingController();

    return Scaffold(
      appBar: PwAppBar(
        title: Strings.nameYourAccount,
      ),
      body: Form(
        key: _formKey,
        child: Container(
          color: Theme.of(context).colorScheme.provenanceNeutral750,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProgressStepper(
                currentStep ?? 0,
                numberOfSteps ?? 1,
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: Spacing.medium,
                ),
              ),
              VerticalSpacer.largeX3(),
              Padding(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: PwText(
                  Strings.nameYourAccountText,
                  style: PwTextStyle.body,
                  textAlign: TextAlign.center,
                  color: PwColor.white,
                ),
              ),
              VerticalSpacer.small(),
              Padding(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: PwText(
                  Strings.infoIsStoredLocallyText,
                  style: PwTextStyle.body,
                  textAlign: TextAlign.center,
                  color: PwColor.white,
                ),
              ),
              VerticalSpacer.xxLarge(),
              Padding(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: _TextFormField(
                  label: Strings.accountName,
                  validator: (value) {
                    return value == null || value.isEmpty
                        ? Strings.required
                        : null;
                  },
                  controller: accountNameProvider,
                ),
              ),
              Expanded(child: Container()),
              Padding(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: PwButton(
                  child: PwText(
                    Strings.continueName,
                    style: PwTextStyle.mBold,
                    color: PwColor.white,
                  ),
                  onPressed: () {
                    if (_formKey.currentState?.validate() == true) {
                      if (flowType == WalletAddImportType.onBoardingRecover ||
                          flowType == WalletAddImportType.dashboardRecover) {
                        Navigator.of(context).push(
                          RecoverAccountScreen(
                            flowType,
                            accountNameProvider.text,
                            currentStep: (currentStep ?? 0) + 1,
                            numberOfSteps: numberOfSteps,
                          ).route(),
                        );
                      } else if (flowType ==
                              WalletAddImportType.onBoardingAdd ||
                          flowType == WalletAddImportType.dashboardAdd) {
                        Navigator.of(context).push(
                          CreatePassphraseScreen(
                            flowType,
                            accountNameProvider.text,
                            currentStep: (currentStep ?? 0) + 1,
                            numberOfSteps: numberOfSteps,
                          ).route(),
                        );
                      }
                    }
                  },
                ),
              ),
              VerticalSpacer.xxLarge(),
              VerticalSpacer.xxLarge(),
            ],
          ),
        ),
      ),
    );
  }
}

class _TextFormField extends StatelessWidget {
  const _TextFormField({
    Key? key,
    required this.label,
    this.keyboardType,
    this.onChanged,
    this.validator,
    this.controller,
  }) : super(key: key);

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
        PwText(
          label,
          color: PwColor.white,
        ),
        const VerticalSpacer.small(),
        TextFormField(
          style: theme.textTheme.body.copyWith(color: theme.colorScheme.white),
          keyboardType: keyboardType,
          autocorrect: false,
          controller: controller,
          onChanged: onChanged,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: validator,
          decoration: InputDecoration(
            hintText: label,
            hintStyle: theme.textTheme.body
                .copyWith(color: theme.colorScheme.provenanceNeutral250),
            fillColor: theme.colorScheme.provenanceNeutral750,
            filled: true,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: theme.colorScheme.provenanceNeutral250,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

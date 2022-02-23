import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provenance_wallet/common/enum/wallet_add_import_type.dart';
import 'package:provenance_wallet/common/pw_design.dart';
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

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
          color: Theme.of(context).colorScheme.neutral750,
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
                  color: PwColor.neutralNeutral,
                ),
              ),
              VerticalSpacer.small(),
              Padding(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: PwText(
                  Strings.infoIsStoredLocallyText,
                  style: PwTextStyle.body,
                  textAlign: TextAlign.center,
                  color: PwColor.neutralNeutral,
                ),
              ),
              VerticalSpacer.xxLarge(),
              Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  bottom: Spacing.small,
                ),
                child: _TextFormField(
                  label: Strings.accountName,
                  autofocus: true,
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
                    color: PwColor.neutralNeutral,
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
              VerticalSpacer.large(),
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
    this.autofocus = false,
  }) : super(key: key);

  final String label;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final TextEditingController? controller;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PwText(
          label,
          color: PwColor.neutralNeutral,
        ),
        VerticalSpacer.small(),
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.neutral550,
                spreadRadius: 6,
              ),
            ],
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          child: TextFormField(
            autofocus: autofocus,
            style: theme.textTheme.body
                .copyWith(color: theme.colorScheme.neutralNeutral),
            keyboardType: keyboardType,
            autocorrect: false,
            controller: controller,
            onChanged: onChanged,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: validator,
            decoration: InputDecoration(
              hintText: label,
              hintStyle: theme.textTheme.body
                  .copyWith(color: theme.colorScheme.neutral250),
              fillColor: theme.colorScheme.neutral750,
              filled: true,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: theme.colorScheme.neutral250,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

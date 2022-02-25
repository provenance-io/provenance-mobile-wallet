import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provenance_wallet/common/enum/wallet_add_import_type.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/common/widgets/pw_text_form_field.dart';
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
        leadingIcon: flowType == WalletAddImportType.dashboardAdd ||
                flowType == WalletAddImportType.dashboardRecover
            ? PwIcons.back
            : null,
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
                child: PwTextFormField(
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

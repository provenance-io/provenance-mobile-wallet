import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provenance_wallet/common/enum/wallet_add_import_type.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/screens/present_information.dart';
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
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.white,
        elevation: 0.0,
        title: PwText(
          Strings.nameYourAccount,
          style: PwTextStyle.h5,
          textAlign: TextAlign.left,
          color: PwColor.globalNeutral550,
        ),
        leading: IconButton(
          icon: PwIcon(
            PwIcons.close,
            size: 24,
            color: Theme.of(context).colorScheme.globalNeutral550,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Container(
          color: Theme.of(context).colorScheme.white,
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
                  top: 12,
                ),
              ),
              SizedBox(
                height: 110,
              ),
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
              SizedBox(
                height: 24,
              ),
              Padding(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: PwText(
                  Strings.nameYourAccountText,
                  style: PwTextStyle.sBold,
                  textAlign: TextAlign.left,
                  color: PwColor.globalNeutral450,
                ),
              ),
              Expanded(child: Container()),
              SizedBox(
                height: 24,
              ),
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
                          PresentInformation(
                            InfoModel(
                              flowType,
                              accountNameProvider.text,
                              Strings.recoverAccount,
                              Strings.inTheFollowingStepsText,
                              Strings.next,
                              currentStep: (currentStep ?? 0) + 1,
                              numberOfSteps: numberOfSteps,
                            ),
                          ).route(),
                        );
                      } else if (flowType ==
                              WalletAddImportType.onBoardingAdd ||
                          flowType == WalletAddImportType.dashboardAdd) {
                        Navigator.of(context).push(
                          PresentInformation(
                            InfoModel(
                              flowType,
                              accountNameProvider.text,
                              Strings.createPassphrase,
                              Strings.theOnlyWayToRecoverYourAccount,
                              Strings.iAmReady,
                              currentStep: (currentStep ?? 0) + 1,
                              numberOfSteps: numberOfSteps,
                            ),
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
        PwText(label),
        const VerticalSpacer.small(),
        TextFormField(
          keyboardType: keyboardType,
          autocorrect: false,
          controller: controller,
          onChanged: onChanged,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: validator,
          decoration: InputDecoration(
            fillColor: theme.colorScheme.white,
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

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_tech_wallet/common/enum/wallet_add_import_type.dart';
import 'package:flutter_tech_wallet/common/fw_design.dart';
import 'package:flutter_tech_wallet/common/widgets/button.dart';
import 'package:flutter_tech_wallet/screens/prepare_recovery_phrase_intro.dart';
import 'package:flutter_tech_wallet/screens/restore_account_intro.dart';
import 'package:flutter_tech_wallet/util/strings.dart';

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
        backgroundColor: Colors.white,
        elevation: 0.0,
        leading: IconButton(
          icon: FwIcon(
            FwIcons.close,
            size: 24,
            color: Color(0xFF3D4151),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.only(top: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      FwText(
                        Strings.nameYourAccount,
                        style: FwTextStyle.extraLarge,
                        textAlign: TextAlign.left,
                        color: FwColor.globalNeutral550,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 40,
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
                  child: FwText(
                    Strings.nameYourAccountText,
                    style: FwTextStyle.sBold,
                    textAlign: TextAlign.left,
                    color: FwColor.globalNeutral450,
                  ),
                ),
                Expanded(child: Container()),
                SizedBox(
                  height: 24,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  child: FwButton(
                    child: FwText(
                      Strings.continueName,
                      style: FwTextStyle.mBold,
                      color: FwColor.white,
                    ),
                    onPressed: () {
                      if (_formKey.currentState?.validate() == true) {
                        if (flowType == WalletAddImportType.onBoardingRecover ||
                            flowType == WalletAddImportType.dashboardRecover) {
                          Navigator.of(context).push(RestoreAccountIntro(
                            flowType,
                            accountNameProvider.text,
                            currentStep: (currentStep ?? 0) + 1,
                            numberOfSteps: numberOfSteps,
                          ).route());
                        } else if (flowType ==
                                WalletAddImportType.onBoardingAdd ||
                            flowType == WalletAddImportType.dashboardAdd) {
                          Navigator.of(context).push(PrepareRecoveryPhraseIntro(
                            flowType,
                            accountNameProvider.text,
                            currentStep: (currentStep ?? 0) + 1,
                            numberOfSteps: numberOfSteps,
                          ).route());
                        }
                      }
                    },
                  ),
                ),
                VerticalSpacer.xxLarge(),
                if (numberOfSteps != null)
                  ProgressStepper(
                    currentStep ?? 0,
                    numberOfSteps ?? 1,
                    padding: EdgeInsets.only(left: 20, right: 20),
                  ),
                if (numberOfSteps != null) VerticalSpacer.xxLarge(),
              ],
            ),
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

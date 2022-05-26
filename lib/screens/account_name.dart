import 'package:provenance_wallet/common/enum/account_add_import_type.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/common/widgets/pw_onboarding_screen.dart';
import 'package:provenance_wallet/common/widgets/pw_text_form_field.dart';
import 'package:provenance_wallet/screens/create_passphrase_screen.dart';
import 'package:provenance_wallet/screens/recover_account_screen.dart';
import 'package:provenance_wallet/util/strings.dart';

class AccountName extends StatefulWidget {
  const AccountName(
    this.flowType, {
    Key? key,
    this.words,
    required this.currentStep,
    this.numberOfSteps,
  }) : super(key: key);

  static final keyNameTextField = ValueKey('$AccountName.name_text_field');
  static final keyContinueButton = ValueKey('$AccountName.continue_button');

  final List<String>? words;
  final int currentStep;
  final int? numberOfSteps;
  final AccountAddImportType flowType;

  @override
  State<AccountName> createState() => _AccountNameState();
}

class _AccountNameState extends State<AccountName> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _textEditingController;

  @override
  void initState() {
    super.initState();

    _textEditingController = TextEditingController();
  }

  @override
  void dispose() {
    _textEditingController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PwAppBar(
        title: Strings.nameYourAccount,
        leadingIcon: widget.flowType == AccountAddImportType.dashboardAdd ||
                widget.flowType == AccountAddImportType.dashboardRecover
            ? PwIcons.back
            : null,
        bottom: ProgressStepper(
          widget.currentStep,
          widget.numberOfSteps ?? 1,
        ),
      ),
      body: Form(
        key: _formKey,
        child: PwOnboardingScreen(
          children: [
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
                key: AccountName.keyNameTextField,
                label: Strings.accountName,
                autofocus: true,
                validator: (value) {
                  return value == null || value.isEmpty
                      ? Strings.required
                      : null;
                },
                controller: _textEditingController,
                onFieldSubmitted: (_) => _submit(),
              ),
            ),
            Expanded(
              child: Container(),
            ),
            Padding(
              padding: EdgeInsets.only(left: 20, right: 20),
              child: PwButton(
                child: PwText(
                  Strings.continueName,
                  key: AccountName.keyContinueButton,
                  style: PwTextStyle.bodyBold,
                  color: PwColor.neutralNeutral,
                ),
                onPressed: () {
                  _submit();
                },
              ),
            ),
            VerticalSpacer.large(),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() == true) {
      if (widget.flowType == AccountAddImportType.onBoardingRecover ||
          widget.flowType == AccountAddImportType.dashboardRecover) {
        Navigator.of(context).push(
          RecoverAccountScreen(
            widget.flowType,
            _textEditingController.text,
            currentStep: widget.currentStep + 1,
            numberOfSteps: widget.numberOfSteps,
          ).route(),
        );
      } else if (widget.flowType == AccountAddImportType.onBoardingAdd ||
          widget.flowType == AccountAddImportType.dashboardAdd) {
        Navigator.of(context).push(
          CreatePassphraseScreen(
            widget.flowType,
            _textEditingController.text,
            currentStep: widget.currentStep + 1,
            numberOfSteps: widget.numberOfSteps,
          ).route(),
        );
      }
    }
  }
}

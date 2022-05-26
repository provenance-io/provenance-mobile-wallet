import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/common/widgets/pw_onboarding_screen.dart';
import 'package:provenance_wallet/common/widgets/pw_text_form_field.dart';
import 'package:provenance_wallet/screens/add_account_flow_bloc.dart';
import 'package:provenance_wallet/screens/add_account_origin.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class AccountName extends StatefulWidget {
  const AccountName({
    Key? key,
  }) : super(key: key);

  static final keyNameTextField = ValueKey('$AccountName.name_text_field');
  static final keyContinueButton = ValueKey('$AccountName.continue_button');

  @override
  State<AccountName> createState() => _AccountNameState();
}

class _AccountNameState extends State<AccountName> {
  static const _screen = AddAccountScreen.accountName;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _bloc = get<AddAccountFlowBloc>();

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
        leadingIcon:
            _bloc.origin == AddAccountOrigin.accounts ? PwIcons.back : null,
        bottom: ProgressStepper(
          _bloc.getCurrentStep(_screen),
          _bloc.totalSteps,
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
                onPressed: _submit,
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
      get<AddAccountFlowBloc>().submitAccountName(_textEditingController.text);
    }
  }
}

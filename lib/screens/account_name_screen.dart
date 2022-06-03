import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/common/widgets/pw_text_form_field.dart';
import 'package:provenance_wallet/screens/add_account_flow_bloc.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:rxdart/rxdart.dart';

class AccountNameScreen extends StatefulWidget {
  const AccountNameScreen({
    required this.mode,
    required this.message,
    required this.leadingIcon,
    required this.name,
    required this.submit,
    required this.popOnSubmit,
    this.currentStep,
    this.totalSteps,
    Key? key,
  }) : super(key: key);

  static final keyNameTextField =
      ValueKey('$AccountNameScreen.name_text_field');
  static final keyContinueButton =
      ValueKey('$AccountNameScreen.continue_button');

  factory AccountNameScreen.single({
    required FieldMode mode,
    required String leadingIcon,
    int? currentStep,
    int? totalSteps,
    Key? key,
  }) {
    final bloc = get<AddAccountFlowBloc>();

    return AccountNameScreen(
      mode: mode,
      leadingIcon: leadingIcon,
      message: Strings.accountNameMessage,
      name: bloc.name,
      submit: bloc.submitAccountName,
      popOnSubmit: false,
      currentStep: currentStep,
      totalSteps: totalSteps,
    );
  }

  factory AccountNameScreen.multi({
    required FieldMode mode,
    required String leadingIcon,
    int? currentStep,
    int? totalSteps,
    Key? key,
  }) {
    final bloc = get<AddAccountFlowBloc>();

    bool pop;
    void Function(String name) submit;

    switch (mode) {
      case FieldMode.initial:
        pop = false;
        submit = bloc.submitMultiSigAccountName;
        break;
      case FieldMode.edit:
        pop = true;
        submit = bloc.setMultiSigName;
        break;
    }

    return AccountNameScreen(
      mode: mode,
      leadingIcon: leadingIcon,
      message: Strings.accountNameMultiSigMessage,
      name: bloc.multiSigName,
      submit: submit,
      popOnSubmit: pop,
      currentStep: currentStep,
      totalSteps: totalSteps,
    );
  }

  final int? currentStep;
  final int? totalSteps;
  final FieldMode mode;
  final String leadingIcon;
  final String message;
  final ValueStream<String> name;
  final void Function(String name) submit;
  final bool popOnSubmit;

  @override
  State<AccountNameScreen> createState() => _AccountNameScreenState();
}

class _AccountNameScreenState extends State<AccountNameScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _subscriptions = CompositeSubscription();

  late final TextEditingController _textEditingController;

  @override
  void initState() {
    super.initState();

    _textEditingController = TextEditingController();
    widget.name.listen((e) {
      _textEditingController.text = e;
    }).addTo(_subscriptions);
  }

  @override
  void dispose() {
    _subscriptions.dispose();
    _textEditingController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String buttonLabel;

    switch (widget.mode) {
      case FieldMode.initial:
        buttonLabel = Strings.continueName;
        break;
      case FieldMode.edit:
        buttonLabel = Strings.multiSigSaveButton;
        break;
    }

    return Scaffold(
      appBar: PwAppBar(
        title: Strings.nameYourAccount,
        leadingIcon: widget.leadingIcon,
        bottom: (widget.currentStep != null && widget.totalSteps != null)
            ? ProgressStepper(
                widget.currentStep!,
                widget.totalSteps!,
              )
            : null,
      ),
      body: Form(
        key: _formKey,
        child: CustomScrollView(slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              children: [
                VerticalSpacer.largeX3(),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Spacing.xxLarge,
                  ),
                  child: PwText(
                    widget.message,
                    style: PwTextStyle.body,
                    textAlign: TextAlign.center,
                    color: PwColor.neutralNeutral,
                  ),
                ),
                VerticalSpacer.xxLarge(),
                Padding(
                  padding: EdgeInsets.only(
                    left: Spacing.xxLarge,
                    right: Spacing.xxLarge,
                    bottom: Spacing.small,
                  ),
                  child: PwTextFormField(
                    key: AccountNameScreen.keyNameTextField,
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
                VerticalSpacer.large(),
                Padding(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  child: PwButton(
                    child: PwText(
                      buttonLabel,
                      key: AccountNameScreen.keyContinueButton,
                      style: PwTextStyle.bodyBold,
                      color: PwColor.neutralNeutral,
                    ),
                    onPressed: _submit,
                  ),
                ),
                VerticalSpacer.largeX4(),
              ],
            ),
          )
        ]),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() == true) {
      widget.submit(_textEditingController.text);

      if (widget.popOnSubmit) {
        Navigator.of(context).pop();
      }
    }
  }
}

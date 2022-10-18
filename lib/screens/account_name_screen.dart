import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/common/widgets/pw_text_form_field.dart';
import 'package:provenance_wallet/screens/field_mode.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:rxdart/rxdart.dart';

abstract class AccountNameBloc {
  ValueStream<String> get name;
  void submitName(String name, FieldMode mode);
}

class AccountNameScreen extends StatefulWidget {
  const AccountNameScreen({
    required this.mode,
    required this.message,
    required this.leadingIcon,
    required this.bloc,
    required this.popOnSubmit,
    Key? key,
  }) : super(key: key);

  static final keyNameTextField =
      ValueKey('$AccountNameScreen.name_text_field');
  static final keyContinueButton =
      ValueKey('$AccountNameScreen.continue_button');

  final FieldMode mode;
  final String leadingIcon;
  final String message;
  final AccountNameBloc bloc;
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
    widget.bloc.name.listen((e) {
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
    final strings = Strings.of(context);
    String buttonLabel;

    switch (widget.mode) {
      case FieldMode.initial:
        buttonLabel = strings.continueName;
        break;
      case FieldMode.edit:
        buttonLabel = strings.multiSigSaveButton;
        break;
    }

    return Scaffold(
      appBar: PwAppBar(
        title: strings.nameYourAccount,
        leadingIcon: widget.leadingIcon,
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
                    horizontal: Spacing.large,
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
                    left: Spacing.large,
                    right: Spacing.large,
                    bottom: Spacing.small,
                  ),
                  child: PwTextFormField(
                    key: AccountNameScreen.keyNameTextField,
                    label: strings.accountName,
                    autofocus: true,
                    validator: (value) {
                      return value == null || value.isEmpty
                          ? strings.required
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
      widget.bloc.submitName(_textEditingController.text, widget.mode);
    }
  }
}

import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/common/widgets/pw_text_form_field.dart';
import 'package:provenance_wallet/screens/account/basic_account_create_flow.dart';
import 'package:provenance_wallet/screens/account/basic_account_recover_flow.dart';
import 'package:provenance_wallet/screens/add_account_origin.dart';
import 'package:provenance_wallet/screens/field_mode.dart';
import 'package:provenance_wallet/screens/multi_sig/multi_sig_connect_dropdown.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:rxdart/rxdart.dart';

abstract class MultiSigAccountNameBloc {
  ValueStream<String> get name;
  void submitMultiSigName(
      String name, FieldMode mode, BasicAccount linkedAccount);
}

class MultiSigAccountNameScreen extends StatefulWidget {
  const MultiSigAccountNameScreen({
    required this.bloc,
    required this.mode,
    required this.message,
    required this.leadingIcon,
    Key? key,
  }) : super(key: key);

  static final keyNameTextField =
      ValueKey('$MultiSigAccountNameScreen.name_text_field');
  static final keyContinueButton =
      ValueKey('$MultiSigAccountNameScreen.continue_button');

  final MultiSigAccountNameBloc bloc;
  final FieldMode mode;
  final String leadingIcon;
  final String message;

  @override
  State<MultiSigAccountNameScreen> createState() =>
      _MultiSigAccountNameScreenState();
}

class _MultiSigAccountNameScreenState extends State<MultiSigAccountNameScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _subscriptions = CompositeSubscription();

  late final TextEditingController _textEditingController;
  BasicAccount? _linkedAccount;
  late bool _isValid;

  @override
  void initState() {
    super.initState();

    _textEditingController = TextEditingController();
    _textEditingController.addListener(_validate);

    widget.bloc.name.listen((e) {
      _textEditingController.text = e;
    }).addTo(_subscriptions);

    _validate();
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
        title: strings.multiSigNameYourAccount,
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
                    key: MultiSigAccountNameScreen.keyNameTextField,
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
                VerticalSpacer.large(),
                Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: Spacing.large,
                  ),
                  child: MultiSigConnectDropDown(
                    onChanged: (e) {
                      setState(() {
                        _linkedAccount = e.account;
                      });
                    },
                    selected: _linkedAccount,
                  ),
                ),
                VerticalSpacer.large(),
                PwTextButton.secondaryAction(
                  context: context,
                  text: Strings.of(context).multiSigCreateLinkedAccount,
                  onPressed: () async {
                    final account =
                        await Navigator.of(context).push<BasicAccount?>(
                      BasicAccountCreateFlow(
                        origin: AddAccountOrigin.accounts,
                      ).route(),
                    );

                    if (account != null) {
                      setState(() {
                        _linkedAccount = account;
                      });
                    }
                  },
                ),
                VerticalSpacer.large(),
                PwTextButton.secondaryAction(
                  context: context,
                  text: Strings.of(context).multiSigRecoverLinkedAccount,
                  onPressed: () async {
                    final account =
                        await Navigator.of(context).push<BasicAccount?>(
                      BasicAccountRecoverFlow(
                        origin: AddAccountOrigin.accounts,
                      ).route(),
                    );

                    if (account != null) {
                      setState(() {
                        _linkedAccount = account;
                      });
                    }
                  },
                ),
                VerticalSpacer.large(),
                Expanded(
                  child: Container(),
                ),
                VerticalSpacer.xLarge(),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Spacing.large,
                  ),
                  child: PwButton(
                    child: PwText(
                      buttonLabel,
                      key: MultiSigAccountNameScreen.keyContinueButton,
                      style: PwTextStyle.bodyBold,
                      color: PwColor.neutralNeutral,
                    ),
                    enabled: _isValid,
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

  void _validate() {
    final valid =
        _textEditingController.text.isNotEmpty && _linkedAccount != null;

    setState(() {
      _isValid = valid;
    });
  }

  void _submit() {
    if (_isValid) {
      widget.bloc.submitMultiSigName(
          _textEditingController.text, widget.mode, _linkedAccount!);
    }
  }
}

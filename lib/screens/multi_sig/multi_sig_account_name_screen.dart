import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/common/widgets/pw_text_form_field.dart';
import 'package:provenance_wallet/screens/field_mode.dart';
import 'package:provenance_wallet/screens/multi_sig/multi_sig_connect_dropdown.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:rxdart/rxdart.dart';

class MultiSigAccountNameScreen extends StatefulWidget {
  const MultiSigAccountNameScreen({
    required this.mode,
    required this.message,
    required this.leadingIcon,
    required this.onSubmit,
    required this.name,
    required this.popOnSubmit,
    required this.coin,
    Key? key,
  }) : super(key: key);

  static final keyNameTextField =
      ValueKey('$MultiSigAccountNameScreen.name_text_field');
  static final keyContinueButton =
      ValueKey('$MultiSigAccountNameScreen.continue_button');

  final ValueStream<String> name;
  final Function(String name, FieldMode mode, BasicAccount linkedAccount)
      onSubmit;

  final FieldMode mode;
  final String leadingIcon;
  final String message;
  final bool popOnSubmit;
  final Coin coin;

  @override
  State<MultiSigAccountNameScreen> createState() =>
      _MultiSigAccountNameScreenState();
}

class _MultiSigAccountNameScreenState extends State<MultiSigAccountNameScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _subscriptions = CompositeSubscription();

  late final TextEditingController _textEditingController;
  BasicAccount? _linkedAccount;

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
                    coin: widget.coin,
                    onChanged: (e) {
                      setState(() {
                        _linkedAccount = e.account;
                      });
                    },
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
                      key: MultiSigAccountNameScreen.keyContinueButton,
                      style: PwTextStyle.bodyBold,
                      color: PwColor.neutralNeutral,
                    ),
                    enabled: _isValid(),
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

  bool _isValid() {
    return _textEditingController.text.isNotEmpty && _linkedAccount != null;
  }

  void _submit() {
    if (_isValid()) {
      widget.onSubmit(
          _textEditingController.text, widget.mode, _linkedAccount!);
    }
  }
}

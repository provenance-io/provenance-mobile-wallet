import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/common/widgets/pw_check_box.dart';
import 'package:provenance_wallet/common/widgets/pw_text_form_field.dart';
import 'package:provenance_wallet/network.dart';
import 'package:provenance_wallet/screens/field_mode.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:rxdart/rxdart.dart';

import 'account/advanced_account_settings.dart';

abstract class AccountNameBloc {
  ValueStream<String> get name;

  ValueStream<Network> get network;
  void submitName({
    required String name,
    required FieldMode mode,
    required Network network,
  });
}

class AccountNameScreen extends StatefulWidget {
  const AccountNameScreen({
    required this.mode,
    required this.message,
    required this.leadingIcon,
    required this.bloc,
    Key? key,
  }) : super(key: key);

  static final keyNameTextField =
      ValueKey('$AccountNameScreen.name_text_field');
  static final keyContinueButton =
      ValueKey('$AccountNameScreen.continue_button');
  static final keyAdvancedSettings =
      ValueKey('$AccountNameScreen.advanced_settings');
  static final keyScrollableRegion =
      ValueKey('$AccountNameScreen.scrollable_region');

  final FieldMode mode;
  final String leadingIcon;
  final String message;
  final AccountNameBloc bloc;

  @override
  State<AccountNameScreen> createState() => _AccountNameScreenState();
}

class _AccountNameScreenState extends State<AccountNameScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _subscriptions = CompositeSubscription();
  final _defaultNetwork = Network.mainNet;
  var _showAdvanced = false;

  late final TextEditingController _nameController;
  late final _network = BehaviorSubject<Network>.seeded(_defaultNetwork);

  var _valid = false;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController();
    _nameController.addListener(() {
      _updateValid();
    });

    widget.bloc.name.listen((e) {
      _nameController.text = e;
    }).addTo(_subscriptions);

    widget.bloc.network.listen((e) {
      _network.add(e);
    }).addTo(_subscriptions);
  }

  @override
  void dispose() {
    _subscriptions.dispose();
    _nameController.dispose();

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
              key: AccountNameScreen.keyScrollableRegion,
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
                    controller: _nameController,
                    onFieldSubmitted: (_) => _submit(),
                  ),
                ),
                VerticalSpacer.large(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.large,
                  ),
                  child: Row(
                    children: [
                      PwCheckBox(
                        key: AccountNameScreen.keyAdvancedSettings,
                        selected: _showAdvanced,
                        onSelect: (selected) {
                          setState(() {
                            _showAdvanced = selected;
                            _network.add(_defaultNetwork);
                          });
                        },
                      ),
                      HorizontalSpacer.large(),
                      PwText(
                        strings.accountAdvancedSettings,
                        color: PwColor.neutralNeutral,
                        style: PwTextStyle.bodyBold,
                      ),
                    ],
                  ),
                ),
                if (_showAdvanced) ...[
                  VerticalSpacer.large(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.large,
                    ),
                    child: AdvancedAccountSettings(
                      network: _network,
                      onNetworkChanged: (coin) {
                        _network.add(coin);
                      },
                    ),
                  ),
                ],
                Expanded(
                  child: Container(),
                ),
                VerticalSpacer.xxLarge(),
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
                    enabled: _valid,
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
      widget.bloc.submitName(
        name: _nameController.text,
        mode: widget.mode,
        network: _network.value,
      );
    }
  }

  void _updateValid() {
    final name = _nameController.text;

    final valid = name.isNotEmpty;
    if (valid != _valid) {
      setState(() {
        _valid = valid;
      });
    }
  }
}

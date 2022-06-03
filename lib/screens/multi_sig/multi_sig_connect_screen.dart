import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/common/widgets/pw_dropdown.dart';
import 'package:provenance_wallet/screens/add_account_flow_bloc.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class MultiSigConnectScreen extends StatefulWidget {
  const MultiSigConnectScreen({
    required this.currentStep,
    required this.totalSteps,
    Key? key,
  }) : super(key: key);

  final int currentStep;
  final int totalSteps;

  @override
  State<MultiSigConnectScreen> createState() => _MultiSigConnectScreenState();
}

class _MultiSigConnectScreenState extends State<MultiSigConnectScreen> {
  static const _defaultValue = _Item(
    name: '-',
  );

  final _keyNextButton = ValueKey('$MultiSigConnectScreen.next_button');

  final _bloc = get<AddAccountFlowBloc>();
  final _accountService = get<AccountService>();

  late final FocusNode _focusNext;
  Future<List<BasicAccount>>? _load;

  var _value = _defaultValue;
  var _boxHasFocus = false;

  @override
  void initState() {
    super.initState();

    _focusNext = FocusNode(debugLabel: 'Next button');
    _load ??= _accountService.getBasicAccounts();
  }

  @override
  void dispose() {
    super.dispose();

    _focusNext.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PwAppBar(
        title: Strings.multiSigConnectTitle,
        leadingIcon: PwIcons.back,
        bottom: ProgressStepper(
          widget.currentStep,
          widget.totalSteps,
        ),
      ),
      body: Container(
        color: Theme.of(context).colorScheme.neutral750,
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  VerticalSpacer.xxLarge(),
                  Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: Spacing.xxLarge,
                    ),
                    child: PwText(
                      Strings.multiSigConnectDesc,
                      style: PwTextStyle.body,
                      color: PwColor.neutral200,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  VerticalSpacer.largeX3(),
                  Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: Spacing.xxLarge,
                    ),
                    child: PwText(
                      Strings.multiSigConnectSelectionLabel,
                      style: PwTextStyle.body,
                      color: PwColor.neutralNeutral,
                    ),
                  ),
                  VerticalSpacer.small(),
                  Focus(
                    skipTraversal: true,
                    onFocusChange: (hasFocus) {
                      setState(() {
                        _boxHasFocus = hasFocus;
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: Spacing.xxLarge,
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: Spacing.medium,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _boxHasFocus
                              ? Theme.of(context).colorScheme.primary500
                              : Theme.of(context).colorScheme.neutral250,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                      child: FutureBuilder<List<TransactableAccount>>(
                          future: _load,
                          builder: (context, snapshot) {
                            final accounts = [
                              _defaultValue,
                            ];

                            final data = snapshot.data;

                            if (data != null) {
                              accounts.addAll(
                                data.map(
                                  (e) => _Item(
                                    name: e.name,
                                    account: e,
                                  ),
                                ),
                              );
                            }

                            return PwDropDown<_Item>(
                              isExpanded: true,
                              autofocus: true,
                              onValueChanged: (value) {
                                setState(() {
                                  _value = value;
                                });

                                // Button must be in enabled state before it
                                // can be focused.
                                Future.delayed(Duration(milliseconds: 100))
                                    .then(
                                  (value) {
                                    _focusNext.requestFocus();
                                  },
                                );
                              },
                              initialValue: _defaultValue,
                              items: accounts,
                              builder: (item) {
                                return PwText(
                                  item.name,
                                  color: PwColor.neutralNeutral,
                                  style: PwTextStyle.body,
                                );
                              },
                            );
                          }),
                    ),
                  ),
                  VerticalSpacer.xxLarge(),
                  Expanded(
                    child: SizedBox(),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: PwButton(
                      focusNode: _focusNext,
                      enabled: _value != _defaultValue,
                      child: PwText(
                        Strings.multiSigNextButton,
                        key: _keyNextButton,
                        style: PwTextStyle.bodyBold,
                        color: PwColor.neutralNeutral,
                      ),
                      onPressed: _submit,
                    ),
                  ),
                  // TODO-Roy: Enable create
                  //
                  // VerticalSpacer.large(),
                  // Padding(
                  //   padding: EdgeInsets.only(left: 20, right: 20),
                  //   child: PwTextButton(
                  //     onPressed: _submit,
                  //     child: PwText(
                  //       Strings.multiSigConnectCreateButton,
                  //       key: _keyNextButton,
                  //       style: PwTextStyle.body,
                  //       color: PwColor.neutralNeutral,
                  //     ),
                  //   ),
                  // ),
                  VerticalSpacer.largeX4(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    final account = _value == _defaultValue ? null : _value.account;
    _bloc.submitMultiSigConnect(account);
  }
}

class _Item {
  const _Item({
    required this.name,
    this.account,
  });

  final String name;
  final TransactableAccount? account;

  @override
  int get hashCode => hashValues(name, account);

  @override
  bool operator ==(Object other) =>
      other is _Item && other.name == name && other.account == account;
}

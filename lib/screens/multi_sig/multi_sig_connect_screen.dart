import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/common/widgets/pw_dropdown.dart';
import 'package:provenance_wallet/screens/add_account_flow.dart';
import 'package:provenance_wallet/screens/add_account_origin.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class MultiSigConnectScreen extends StatefulWidget {
  const MultiSigConnectScreen({
    required this.onAccount,
    required this.enableCreate,
    this.currentStep,
    this.totalSteps,
    Key? key,
  }) : super(key: key);

  final void Function(BasicAccount? account) onAccount;
  final bool enableCreate;
  final int? currentStep;
  final int? totalSteps;

  @override
  State<MultiSigConnectScreen> createState() => _MultiSigConnectScreenState();
}

class _MultiSigConnectScreenState extends State<MultiSigConnectScreen> {
  static const _defaultValue = _Item(
    name: '-',
  );

  final _keyNextButton = ValueKey('$MultiSigConnectScreen.next_button');
  final _accountService = get<AccountService>();

  late final FocusNode _focusNext;

  var _value = _defaultValue;
  var _boxHasFocus = false;
  List<_Item>? _items;

  Future<void> _load(Account? selected) async {
    final items = [
      _defaultValue,
    ];

    final accounts = await _accountService.getBasicAccounts();
    items.addAll(
      accounts.map(
        (e) => _Item(
          name: e.name,
          account: e,
        ),
      ),
    );

    setState(() {
      _items = items;
      _value = items.firstWhere((e) => e.account?.id == selected?.id);
    });
  }

  @override
  void initState() {
    super.initState();

    _focusNext = FocusNode(debugLabel: 'Next button');
    _load(null);
  }

  @override
  void dispose() {
    super.dispose();

    _focusNext.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentStep = widget.currentStep;
    final totalSteps = widget.totalSteps;
    final items = _items;

    return Scaffold(
      appBar: PwAppBar(
        title: Strings.multiSigConnectTitle,
        leadingIcon: PwIcons.back,
        bottom: currentStep == null || totalSteps == null
            ? null
            : ProgressStepper(
                currentStep,
                totalSteps,
              ),
      ),
      body: Container(
        color: Theme.of(context).colorScheme.neutral750,
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
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
                  Row(
                    children: [
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
                      Expanded(
                        child: SizedBox(),
                      ),
                    ],
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
                      child: items == null
                          ? Container()
                          : PwDropDown<_Item>(
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
                              value: _value,
                              items: items,
                              builder: (item) {
                                return PwText(
                                  item.name,
                                  color: PwColor.neutralNeutral,
                                  style: PwTextStyle.body,
                                );
                              },
                            ),
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
                      onPressed: () {
                        final account =
                            _value == _defaultValue ? null : _value.account;
                        widget.onAccount(account);
                      },
                    ),
                  ),
                  if (widget.enableCreate) VerticalSpacer.large(),
                  if (widget.enableCreate)
                    Padding(
                      padding: EdgeInsets.only(left: 20, right: 20),
                      child: PwTextButton(
                        onPressed: () async {
                          final account = await Navigator.push(
                            context,
                            AddAccountFlow(
                              origin: AddAccountOrigin.accounts,
                              includeMultiSig: false,
                            ).route<Account>(),
                          );

                          if (account != null) {
                            _load(account);
                          }
                        },
                        child: PwText(
                          Strings.multiSigConnectCreateButton,
                          key: _keyNextButton,
                          style: PwTextStyle.body,
                          color: PwColor.neutralNeutral,
                        ),
                      ),
                    ),
                  VerticalSpacer.largeX4(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Item {
  const _Item({
    required this.name,
    this.account,
  });

  final String name;
  final BasicAccount? account;

  @override
  int get hashCode => hashValues(name, account?.id);

  @override
  bool operator ==(Object other) =>
      other is _Item && other.name == name && other.account?.id == account?.id;
}

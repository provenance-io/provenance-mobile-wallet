import 'package:collection/collection.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_dropdown.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

const defaultValue = MultiSigConnectDropdownItem(
  name: '-',
);

class MultiSigConnectDropDown extends StatefulWidget {
  const MultiSigConnectDropDown({
    required this.coin,
    required this.onChanged,
    this.selected,
    Key? key,
  }) : super(key: key);

  final Coin coin;
  final void Function(MultiSigConnectDropdownItem item) onChanged;
  final Account? selected;

  @override
  State<MultiSigConnectDropDown> createState() =>
      _MultiSigConnectDropDownState();
}

class _MultiSigConnectDropDownState extends State<MultiSigConnectDropDown> {
  final _accountService = get<AccountService>();

  late final FocusNode _focusNext;

  var _value = defaultValue;
  var _boxHasFocus = false;
  var _items = <MultiSigConnectDropdownItem>[];

  @override
  void initState() {
    super.initState();

    _focusNext = FocusNode(debugLabel: 'Next button');
    _load(widget.selected);
  }

  @override
  void dispose() {
    super.dispose();

    _focusNext.dispose();
  }

  @override
  void didUpdateWidget(covariant MultiSigConnectDropDown oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.selected?.id != widget.selected?.id) {
      _load(widget.selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      textDirection: TextDirection.ltr,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PwText(
          Strings.of(context).multiSigLinkedAccount,
          color: PwColor.neutralNeutral,
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
            child: PwDropDown<MultiSigConnectDropdownItem>(
              isExpanded: true,
              autofocus: true,
              onValueChanged: (value) {
                setState(() {
                  _value = value;
                });

                widget.onChanged(value);

                // Button must be in enabled state before it
                // can be focused.
                Future.delayed(Duration(milliseconds: 100)).then(
                  (value) {
                    _focusNext.requestFocus();
                  },
                );
              },
              value: _value,
              items: _items,
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
      ],
    );
  }

  Future<void> _load(Account? selected) async {
    final accounts = await _accountService.getBasicAccounts();

    var items = accounts
        .where((e) => e.coin == widget.coin)
        .map(
          (e) => MultiSigConnectDropdownItem(
            name: e.name,
            account: e,
          ),
        )
        .toList();

    if (items.isEmpty) {
      items = [
        defaultValue,
      ];
    }

    final value = items.firstWhereOrNull(
            (e) => e.account?.id != null && e.account?.id == selected?.id) ??
        items.first;

    setState(() {
      _items = items;
      _value = value;
    });

    widget.onChanged(value);
  }
}

class MultiSigConnectDropdownItem {
  const MultiSigConnectDropdownItem({
    required this.name,
    this.account,
  });

  final String name;
  final BasicAccount? account;

  @override
  int get hashCode => hashValues(name, account?.id);

  @override
  bool operator ==(Object other) =>
      other is MultiSigConnectDropdownItem &&
      other.name == name &&
      other.account?.id == account?.id;
}

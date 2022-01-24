import 'package:flutter/cupertino.dart';

import 'package:provenance_wallet/common/fw_design.dart';
import 'package:provenance_wallet/common/widgets/fw_divider.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:prov_wallet_flutter/prov_wallet_flutter.dart';

class MyAccount extends StatefulWidget {
  const MyAccount({Key? key}) : super(key: key);

  @override
  _MyAccountState createState() => _MyAccountState();
}

class _MyAccountState extends State<MyAccount> {
  static const _divider = FwDivider(
    indent: Spacing.large,
    endIndent: Spacing.large,
    height: 1,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        leading: IconButton(
          icon: FwIcon(
            FwIcons.close,
            size: 24,
            color: Theme.of(context).colorScheme.globalNeutral500,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: FwText(
          Strings.myAccount,
          color: FwColor.globalNeutral550,
          style: FwTextStyle.h6,
        ),
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            textDirection: TextDirection.ltr,
            children: [
              _LinkItem(
                text: Strings.linkedServices,
                // count: 1,
                onTap: () {
                  // TODO: open linked services screen.
                },
              ),
              _CategoryLabel(Strings.security),
              _FutureToggleItem(
                text: Strings.faceId,
                getValue: ProvWalletFlutter.getUseBiometry,
                setValue: (value) => ProvWalletFlutter.setUseBiometry(
                  useBiometry: value,
                ),
              ),
              _divider,
              _LinkItem(
                text: Strings.pinCode,
                onTap: () {
                  // TODO: open pin code screen.
                },
              ),
              _divider,
              _LinkItem(
                text: Strings.notifications,
                onTap: () {
                  // TODO: Open notifications screen.
                },
              ),
              _CategoryLabel(Strings.general),
              _LinkItem(
                text: Strings.faq,
                onTap: () {
                  // TODO: open FAQ screen.
                },
              ),
              _divider,
              _LinkItem(
                text: Strings.sendFeedback,
                onTap: () {
                  // TODO: open send feedback screen.
                },
              ),
              _divider,
              _LinkItem(
                text: Strings.contactUs,
                onTap: () {
                  // TODO: open contact us screen.
                },
              ),
              _divider,
              _LinkItem(
                text: Strings.policiesAndTerms,
                onTap: () {
                  // TODO: open policies & terms screen.
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryLabel extends StatelessWidget {
  const _CategoryLabel(
    this.text, {
    Key? key,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: Spacing.large,
      ),
      padding: EdgeInsets.only(
        top: Spacing.large,
        bottom: Spacing.small,
      ),
      child: FwText(
        text,
        color: FwColor.globalNeutral550,
        style: FwTextStyle.mBold,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _LinkItem extends StatelessWidget {
  const _LinkItem({
    required this.text,
    required this.onTap,
    this.count,
    Key? key,
  }) : super(key: key);

  final String text;
  final void Function() onTap;
  final int? count;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 64,
        margin: EdgeInsets.symmetric(
          horizontal: Spacing.large,
        ),
        child: Row(
          children: [
            _ItemLabel(
              text: text,
            ),
            if (count != null) _ItemCount(count: count!),
            Expanded(
              child: Container(
                alignment: Alignment.centerRight,
                margin: EdgeInsets.only(
                  right: Spacing.large,
                ),
                child: FwIcon(
                  FwIcons.caret,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FutureToggleItem extends StatefulWidget {
  const _FutureToggleItem({
    required this.text,
    required this.getValue,
    required this.setValue,
    Key? key,
  }) : super(key: key);

  final String text;
  final Future<bool> Function() getValue;
  final Future<bool> Function(bool) setValue;

  @override
  __FutureToggleItemState createState() => __FutureToggleItemState();
}

class __FutureToggleItemState extends State<_FutureToggleItem> {
  bool? _value;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _getValue();
  }

  @override
  Widget build(BuildContext context) {
    return _ToggleItem(
      text: widget.text,
      value: _value,
      onChanged: (value) async {
        await widget.setValue(value);
        await _getValue();
      },
    );
  }

  Future _getValue() async {
    final value = await widget.getValue();
    if (value != _value) {
      setState(() {
        _value = value;
      });
    }
  }
}

class _ToggleItem extends StatelessWidget {
  const _ToggleItem({
    required this.text,
    required this.value,
    required this.onChanged,
    Key? key,
  }) : super(key: key);

  final String text;
  final bool? value;
  final void Function(bool) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      margin: EdgeInsets.symmetric(
        horizontal: Spacing.large,
      ),
      child: Row(
        children: [
          _ItemLabel(
            text: text,
          ),
          Expanded(
            child: Container(
              alignment: Alignment.centerRight,
              margin: EdgeInsets.only(
                right: Spacing.medium,
              ),
              child: value == null
                  ? Container()
                  : CupertinoSwitch(
                      value: value!,
                      onChanged: onChanged,
                      trackColor: Theme.of(context).colorScheme.midGrey,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemLabel extends StatelessWidget {
  const _ItemLabel({
    required this.text,
    this.onTap,
    Key? key,
  }) : super(key: key);

  final String text;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: Spacing.medium,
      ),
      child: FwText(
        text,
        color: FwColor.globalNeutral500,
        style: FwTextStyle.sBold,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _ItemCount extends StatelessWidget {
  const _ItemCount({
    required this.count,
    Key? key,
  }) : super(key: key);

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.midGrey,
      ),
      padding: EdgeInsets.all(6),
      child: FwText(
        count.toString(),
        style: FwTextStyle.xsBold,
      ),
    );
  }
}

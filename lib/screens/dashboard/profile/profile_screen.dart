import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/services/wallet_service.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const _divider = PwListDivider();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.neutral750,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.neutral750,
        elevation: 0.0,
        leading: Container(),
        title: PwText(
          Strings.profile,
          style: PwTextStyle.subhead,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          textDirection: TextDirection.ltr,
          children: [
            _CategoryLabel(Strings.security),
            _divider,
            _FutureToggleItem(
              text: Strings.faceId,
              getValue: get<WalletService>().getUseBiometry,
              setValue: (value) => get<WalletService>().setUseBiometry(
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
            _CategoryLabel(Strings.general),
            _divider,
            _LinkItem(
              text: Strings.aboutProvenanceBlockchain,
              onTap: () {
                launchUrl('https://provenance.io/');
              },
            ),
            _divider,
            _LinkItem(
              text: Strings.moreInformation,
              onTap: () {
                launchUrl('https://docs.provenance.io/');
              },
            ),
            _divider,
          ],
        ),
      ),
    );
  }

  void launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
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
        horizontal: Spacing.xxLarge,
      ),
      padding: EdgeInsets.only(
        top: Spacing.xxLarge,
        bottom: Spacing.large,
      ),
      child: PwText(
        text,
        style: PwTextStyle.title,
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
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 64,
        margin: EdgeInsets.symmetric(
          horizontal: Spacing.xxLarge,
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
                child: PwIcon(
                  PwIcons.caret,
                  color: Theme.of(context).colorScheme.neutralNeutral,
                  size: 10,
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
  final Future Function(bool) setValue;

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
        horizontal: Spacing.xxLarge,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _ItemLabel(
            text: text,
          ),
          Expanded(
            child: Container(),
          ),
          Container(
            alignment: Alignment.centerRight,
            margin: EdgeInsets.only(
              right: Spacing.medium,
            ),
            child: value == null
                ? Container()
                : FlutterSwitch(
                    value: value!,
                    onToggle: onChanged,
                    inactiveColor: Theme.of(context).colorScheme.neutral450,
                    activeColor: Theme.of(context).colorScheme.primary550,
                    toggleColor: Theme.of(context).colorScheme.neutral800,
                    padding: 3,
                    height: 20,
                    width: 40,
                    borderRadius: Spacing.large,
                    toggleSize: 14.0,
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
      child: PwText(
        text,
        style: PwTextStyle.body,
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
        color: Theme.of(context).colorScheme.secondary250,
      ),
      padding: EdgeInsets.all(6),
      child: PwText(
        count.toString(),
        style: PwTextStyle.xsBold,
      ),
    );
  }
}

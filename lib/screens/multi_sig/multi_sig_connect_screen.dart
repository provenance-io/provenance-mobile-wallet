import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/screens/multi_sig/multi_sig_connect_dropdown.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/util/strings.dart';

class MultiSigConnectScreen extends StatefulWidget {
  const MultiSigConnectScreen({
    required this.onSubmit,
    Key? key,
  }) : super(key: key);

  final void Function(BuildContext context, BasicAccount account) onSubmit;

  @override
  State<MultiSigConnectScreen> createState() => _MultiSigConnectScreenState();
}

class _MultiSigConnectScreenState extends State<MultiSigConnectScreen> {
  final _keyNextButton = ValueKey('$MultiSigConnectScreen.next_button');

  late final FocusNode _focusNext;

  var _value = defaultValue;

  @override
  void initState() {
    super.initState();

    _focusNext = FocusNode(debugLabel: 'Next button');
  }

  @override
  void dispose() {
    super.dispose();

    _focusNext.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = Strings.of(context);

    return Scaffold(
      appBar: PwAppBar(
        title: strings.multiSigConnectTitle,
        leadingIcon: PwIcons.back,
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
                      horizontal: Spacing.large,
                    ),
                    child: PwText(
                      strings.multiSigConnectDesc,
                      style: PwTextStyle.body,
                      color: PwColor.neutral200,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  VerticalSpacer.largeX3(),
                  Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: Spacing.large,
                    ),
                    child: MultiSigConnectDropDown(
                      onChanged: (item) {
                        setState(() {
                          _value = item;
                        });
                      },
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
                      enabled: _value != defaultValue,
                      child: PwText(
                        strings.multiSigNextButton,
                        key: _keyNextButton,
                        style: PwTextStyle.bodyBold,
                        color: PwColor.neutralNeutral,
                      ),
                      onPressed: () {
                        final account =
                            _value == defaultValue ? null : _value.account;

                        if (account != null) {
                          widget.onSubmit(context, account);
                        }
                      },
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

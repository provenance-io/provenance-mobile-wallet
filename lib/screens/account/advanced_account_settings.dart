import 'package:flutter/cupertino.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/network.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:rxdart/rxdart.dart';

class AdvancedAccountSettings extends StatefulWidget {
  const AdvancedAccountSettings({
    required this.network,
    required this.onNetworkChanged,
    Key? key,
  }) : super(key: key);

  static ValueKey keyNetwork(Network network) =>
      ValueKey('$AdvancedAccountSettings.${network.chainId}');

  final ValueStream<Network> network;
  final void Function(Network network) onNetworkChanged;

  @override
  State<AdvancedAccountSettings> createState() =>
      _AdvancedAccountSettingsState();
}

class _AdvancedAccountSettingsState extends State<AdvancedAccountSettings> {
  final _subscriptions = CompositeSubscription();

  @override
  void dispose() {
    _subscriptions.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final networks = Network.values.asMap().map(
          (k, v) => MapEntry(
            v,
            _buildNetwork(context, v),
          ),
        );

    final strings = Strings.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      textDirection: TextDirection.ltr,
      children: [
        Row(
          children: [
            PwText(
              strings.accountAdvancedSettingsNetwork,
              color: PwColor.neutralNeutral,
            ),
          ],
        ),
        VerticalSpacer.small(),
        SizedBox(
          height: 30,
          child: StreamBuilder<Network>(
              initialData: widget.network.valueOrNull,
              stream: widget.network,
              builder: (context, snapshot) {
                final network = snapshot.data;
                if (network == null) {
                  return Container();
                }

                return CupertinoSegmentedControl<Network>(
                    children: networks,
                    groupValue: network,
                    selectedColor: Theme.of(context).colorScheme.primary550,
                    unselectedColor: Theme.of(context).colorScheme.neutral600,
                    borderColor: Theme.of(context).backgroundColor,
                    padding: EdgeInsets.zero,
                    onValueChanged: (network) {
                      widget.onNetworkChanged(network);
                    });
              }),
        ),
      ],
    );
  }

  Widget _buildNetwork(BuildContext context, Network network) => Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.small,
          vertical: Spacing.xSmall,
        ),
        child: PwText(
          key: AdvancedAccountSettings.keyNetwork(network),
          network.label.get(context),
          color: PwColor.neutralNeutral,
          style: PwTextStyle.footnote,
        ),
      );
}

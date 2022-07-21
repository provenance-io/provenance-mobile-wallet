import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/home/transactions/details_item.dart';
import 'package:provenance_wallet/services/account_service/wallet_connect_session_state.dart';
import 'package:provenance_wallet/services/wallet_connect_service/wallet_connect_service.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class ConnectionDetailsModal extends StatelessWidget {
  const ConnectionDetailsModal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final walletConnectService = get<WalletConnectService>();

    return Scaffold(
      appBar: PwAppBar(
        title: Strings.connectionDetails,
      ),
      body: Container(
        color: Theme.of(context).colorScheme.neutral750,
        child: StreamBuilder<WalletConnectSessionState>(
          initialData: walletConnectService.sessionEvents.state.value,
          stream: walletConnectService.sessionEvents.state,
          builder: (context, snapshot) {
            final name = snapshot.data?.details?.name ?? Strings.unknown;
            final address =
                snapshot.data?.details?.url.toString() ?? Strings.unknown;

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                DetailsItem(
                  title: Strings.platform,
                  padding: EdgeInsets.symmetric(
                    horizontal: Spacing.xxLarge,
                    vertical: Spacing.xLarge,
                  ),
                  endChild: Row(
                    children: [
                      PwText(
                        name,
                        style: PwTextStyle.body,
                      ),
                    ],
                  ),
                ),
                PwListDivider(
                  indent: Spacing.xxLarge,
                ),
                DetailsItem(
                  title: Strings.url,
                  padding: EdgeInsets.symmetric(
                    horizontal: Spacing.xxLarge,
                    vertical: Spacing.xLarge,
                  ),
                  endChild: Flexible(
                    child: PwText(
                      address,
                      maxLines: 2,
                      textAlign: TextAlign.end,
                    ),
                  ),
                ),
                Expanded(child: Container()),
                Padding(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  child: PwButton(
                    child: PwText(
                      Strings.disconnect,
                      style: PwTextStyle.bodyBold,
                      color: PwColor.neutralNeutral,
                    ),
                    onPressed: () async {
                      final walletConnectSession = get<WalletConnectService>();
                      walletConnectSession.disconnectSession();
                      Navigator.of(context).pop(null);
                    },
                  ),
                ),
                VerticalSpacer.largeX4(),
              ],
            );
          },
        ),
      ),
    );
  }
}

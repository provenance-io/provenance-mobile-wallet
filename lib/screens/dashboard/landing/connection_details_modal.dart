import 'package:provenance_blockchain_wallet/common/pw_design.dart';
import 'package:provenance_blockchain_wallet/common/widgets/button.dart';
import 'package:provenance_blockchain_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_blockchain_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_blockchain_wallet/screens/dashboard/dashboard_bloc.dart';
import 'package:provenance_blockchain_wallet/screens/dashboard/transactions/details_item.dart';
import 'package:provenance_blockchain_wallet/services/wallet_service/wallet_connect_session_state.dart';
import 'package:provenance_blockchain_wallet/util/get.dart';
import 'package:provenance_blockchain_wallet/util/strings.dart';

class ConnectionDetailsModal extends StatelessWidget {
  const ConnectionDetailsModal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = get<DashboardBloc>();

    return Scaffold(
      appBar: PwAppBar(
        title: Strings.connectionDetails,
      ),
      body: Container(
        color: Theme.of(context).colorScheme.neutral750,
        child: StreamBuilder<WalletConnectSessionState>(
          initialData: bloc.sessionEvents.state.value,
          stream: bloc.sessionEvents.state,
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
                // TODO: Put Required action items here.
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
                      bloc.disconnectSession();
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

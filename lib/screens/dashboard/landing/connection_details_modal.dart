import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/dashboard/dashboard_bloc.dart';
import 'package:provenance_wallet/screens/dashboard/transactions/details_item.dart';
import 'package:provenance_wallet/services/wallet_service/wallet_connect_session_state.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

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
        child: Column(
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
                children: const [
                  PwText(
                    Strings.dlob,
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
              endChild: StreamBuilder<WalletConnectSessionState>(
                initialData: bloc.sessionEvents.state.value,
                stream: bloc.sessionEvents.state,
                builder: (context, snapshot) {
                  final address =
                      snapshot.data?.details?.url.toString() ?? Strings.unknown;

                  return Flexible(
                    child: PwText(
                      address,
                      maxLines: 2,
                      textAlign: TextAlign.end,
                    ),
                  );
                },
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
        ),
      ),
    );
  }
}

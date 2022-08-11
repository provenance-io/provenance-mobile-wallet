import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_dialog.dart';
import 'package:provenance_wallet/screens/home/dashboard/connection_details_modal.dart';
import 'package:provenance_wallet/screens/qr_code_scanner.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/account_service/wallet_connect_session_state.dart';
import 'package:provenance_wallet/services/account_service/wallet_connect_session_status.dart';
import 'package:provenance_wallet/services/wallet_connect_service/wallet_connect_service.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/logs/logging.dart';
import 'package:provenance_wallet/util/strings.dart';

class WalletConnectButton extends StatelessWidget {
  WalletConnectButton({Key? key}) : super(key: key);

  final _accountService = get<AccountService>();
  final _walletConnectService = get<WalletConnectService>();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<WalletConnectSessionState>(
      initialData: _walletConnectService.sessionEvents.state.value,
      stream: _walletConnectService.sessionEvents.state,
      builder: (context, snapshot) {
        final connected =
            snapshot.data?.status == WalletConnectSessionStatus.connected;
        Widget icon;
        switch (snapshot.data?.status) {
          case WalletConnectSessionStatus.disconnected:
            icon = PwIcon(
              PwIcons.qr,
              color: Theme.of(context).colorScheme.neutralNeutral,
              size: 48.0,
            );
            break;
          case WalletConnectSessionStatus.connected:
            icon = PwIcon(
              PwIcons.linked,
              color: Theme.of(context).colorScheme.neutralNeutral,
              size: 48.0,
            );
            break;
          default:
            icon = Stack(
              alignment: AlignmentDirectional.center,
              children: [
                PwIcon(
                  PwIcons.linked,
                  color: Theme.of(context)
                      .colorScheme
                      .neutralNeutral
                      .withAlpha(128),
                  size: 48.0,
                ),
                SizedBox(
                  child: CircularProgressIndicator(
                    strokeWidth: 1,
                    color: Theme.of(context).colorScheme.neutralNeutral,
                  ),
                  height: 48,
                  width: 48,
                ),
              ],
            );
        }

        return Padding(
          padding: EdgeInsets.only(
            right: Spacing.large,
          ),
          child: GestureDetector(
            onTap: () async {
              if (connected) {
                showDialog(
                  useSafeArea: true,
                  barrierColor: Theme.of(context).colorScheme.neutral750,
                  context: context,
                  builder: (context) => ConnectionDetailsModal(),
                );
              } else {
                final accountId = _accountService.events.selected.value?.id;

                if (accountId != null) {
                  final addressData = await Navigator.of(
                    context,
                    rootNavigator: true,
                  ).push(
                    QRCodeScanner(
                      isValidCallback: (input) {
                        return Future.value(input.isNotEmpty);
                      },
                    ).route(),
                  );

                  if (addressData != null) {
                    final success = await _walletConnectService
                        .connectSession(accountId, addressData)
                        .catchError((err) {
                      PwDialog.showError(
                        context,
                        message: Strings.of(context).walletConnectError,
                        error: err,
                      );

                      logError(
                        'Failed to connect session',
                        error: err,
                      );

                      return false;
                    });

                    if (!success) {
                      PwDialog.showError(
                        context,
                        message: Strings.of(context).walletConnectFailed,
                      );
                    }
                  }
                }
              }
            },
            child: icon,
          ),
        );
      },
    );
  }
}

import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_dialog.dart';
import 'package:provenance_wallet/screens/home/dashboard/connection_details_modal.dart';
import 'package:provenance_wallet/screens/qr_code_scanner.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/services/wallet_connect_service/models/wallet_connect_session_state.dart';
import 'package:provenance_wallet/services/wallet_connect_service/models/wallet_connect_session_status.dart';
import 'package:provenance_wallet/services/wallet_connect_service/wallet_connect_service.dart';
import 'package:provenance_wallet/util/extensions/color_extension.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/logs/logging.dart';
import 'package:provenance_wallet/util/strings.dart';

class WalletConnectButton extends StatelessWidget {
  WalletConnectButton({Key? key}) : super(key: key);

  final _accountService = get<AccountService>();
  final _walletConnectService = get<WalletConnectService>();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<TransactableAccount?>(
        initialData: _accountService.events.selected.valueOrNull,
        stream: _accountService.events.selected,
        builder: (context, snapshot) {
          final account = snapshot.data;
          if (account is! TransactableAccount) {
            return _IconButton(
              icon: PwIcon(
                PwIcons.qr,
                color:
                    Theme.of(context).colorScheme.neutralNeutral.asDisabled(),
                size: 48.0,
              ),
            );
          }

          return StreamBuilder<WalletConnectSessionState>(
            initialData: _walletConnectService.sessionEvents.state.value,
            stream: _walletConnectService.sessionEvents.state,
            builder: (context, snapshot) {
              final status = snapshot.data?.status ??
                  WalletConnectSessionStatus.disconnected;

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

              return _IconButton(
                onPressed: () {
                  _buttonPressed(context, status, account);
                },
                icon: icon,
              );
            },
          );
        });
  }

  void _buttonPressed(BuildContext context, WalletConnectSessionStatus status,
      Account account) async {
    if (status == WalletConnectSessionStatus.connected) {
      showDialog(
        useSafeArea: true,
        barrierColor: Theme.of(context).colorScheme.neutral750,
        context: context,
        builder: (context) => ConnectionDetailsModal(),
      );
    } else if (status == WalletConnectSessionStatus.connecting) {
      showDialog(
        useSafeArea: true,
        barrierColor: Theme.of(context).colorScheme.neutral750,
        context: context,
        builder: (context) => ConnectionDetailsModal(),
      );
    } else {
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
            .connectSession(account.id, addressData)
            .catchError((err) {
          PwDialog.showError(
            context: context,
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
            context: context,
            message: Strings.of(context).walletConnectFailed,
          );
        }
      }
    }
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({
    required this.icon,
    this.onPressed,
    Key? key,
  }) : super(key: key);

  final Widget icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: icon,
        onPressed: onPressed,
      ),
    );
  }
}

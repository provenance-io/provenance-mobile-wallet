import 'package:provenance_wallet/clients/multi_sig_client/multi_sig_client.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/util/get.dart';

Future<bool> tryActivateAccount(MultiAccount pendingAccount) async {
  final multiSigClient = get<MultiSigClient>();
  final accountService = get<AccountService>();

  var activated = false;

  final remoteAccount = await multiSigClient.getAccount(
    remoteId: pendingAccount.remoteId,
    signerAddress: pendingAccount.linkedAccount.address,
    coin: pendingAccount.linkedAccount.coin,
  );

  if (remoteAccount != null) {
    final active = remoteAccount.signers.every((e) => e.publicKey != null);
    if (active) {
      await accountService.activateMultiAccount(
        id: pendingAccount.id,
        signers: remoteAccount.signers,
      );

      activated = true;
    }
  }

  return activated;
}

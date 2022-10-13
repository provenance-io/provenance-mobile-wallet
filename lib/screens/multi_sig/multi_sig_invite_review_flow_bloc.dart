import 'package:provenance_wallet/clients/multi_sig_client/models/multi_sig_remote_account.dart';
import 'package:provenance_wallet/clients/multi_sig_client/multi_sig_client.dart';
import 'package:provenance_wallet/screens/multi_sig/multi_sig_invite_review_flow.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/util/get.dart';

class MultiSigInviteReviewFlowBloc {
  MultiSigInviteReviewFlowBloc({
    required String inviteId,
    required MultiSigRemoteAccount remoteAccount,
    required MultiSigInviteReviewFlowNavigator navigator,
  })  : _inviteId = inviteId,
        _remoteAccount = remoteAccount,
        _navigator = navigator;

  final _accountService = get<AccountService>();
  final _multiSigClient = get<MultiSigClient>();

  final String _inviteId;
  final MultiSigRemoteAccount _remoteAccount;
  final MultiSigInviteReviewFlowNavigator _navigator;

  void showChooseAccount() {
    _navigator.showChooseAccount();
  }

  Future<void> showCreateNewAccount() async {
    final account = await _navigator.showCreateLinkedAccount();
    final multiAccount = await _register(account);

    if (account != null) {
      _navigator.endFlow(multiAccount);
    }
  }

  void showLinkExistingAccount() {
    _navigator.showLinkExistingAccount();
  }

  void showReviewInvitationDetails() {
    _navigator.showReviewInvitationDetails();
  }

  Future<void> submitLinkedAccount(BasicAccount? account) async {
    final multiAccount = await _register(account);

    _navigator.endFlow(multiAccount);
  }

  void submitMaybeLater() {
    _navigator.endFlow(null);
  }

  Future<void> declineInvite() async {
    _navigator.endFlow(null);
  }

  Future<MultiAccount?> _register(BasicAccount? account) async {
    MultiAccount? multiAccount;

    if (account != null) {
      final signer = await _multiSigClient.register(
        inviteId: _inviteId,
        publicKey: account.publicKey,
      );
      if (signer != null) {
        multiAccount = await _accountService.addMultiAccount(
          name: _remoteAccount.name,
          coin: account.publicKey.coin,
          linkedAccountId: account.id,
          remoteId: _remoteAccount.remoteId,
          cosignerCount: _remoteAccount.signers.length,
          signaturesRequired: _remoteAccount.signersRequired,
          inviteIds: _remoteAccount.signers.map((e) => e.inviteId).toList(),
        );
      }
    }

    return multiAccount;
  }
}

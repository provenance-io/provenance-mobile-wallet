import 'package:provenance_wallet/clients/multi_sig_client/models/multi_sig_register_result.dart';
import 'package:provenance_wallet/clients/multi_sig_client/models/multi_sig_remote_account.dart';
import 'package:provenance_wallet/clients/multi_sig_client/multi_sig_client.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/modal_loading.dart';
import 'package:provenance_wallet/common/widgets/pw_dialog.dart';
import 'package:provenance_wallet/screens/multi_sig/multi_sig_connect_screen.dart';
import 'package:provenance_wallet/screens/multi_sig/multi_sig_invite_review_flow.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/util/get.dart';

class MultiSigInviteReviewFlowBloc implements MultiSigConnectBloc {
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

  Future<void> showCreateNewAccount(BuildContext context) async {
    final account = await _navigator.showCreateLinkedAccount();
    final multiAccount = await _register(context, account);

    if (multiAccount != null) {
      _navigator.endFlow(
        MultiSigAddResult(multiAccount),
      );
    }
  }

  void showLinkExistingAccount() {
    _navigator.showLinkExistingAccount();
  }

  void showReviewInvitationDetails() {
    _navigator.showReviewInvitationDetails();
  }

  @override
  Future<void> submitMultiSigConnect(
      BuildContext context, BasicAccount account) async {
    ModalLoadingRoute.showLoading(context);

    final multiAccount = await _register(context, account);

    _navigator.endFlow(
      MultiSigAddResult(multiAccount),
    );
  }

  void submitMaybeLater() {
    _navigator.endFlow(
      MultiSigAddResult(),
    );
  }

  Future<void> declineInvite() async {
    _navigator.endFlow(null);
  }

  Future<MultiAccount?> _register(
      BuildContext context, BasicAccount? account) async {
    MultiAccount? multiAccount;

    if (account != null) {
      MultiSigRegisterResult? result;

      ModalLoadingRoute.showLoading(context);

      try {
        result = await _multiSigClient.register(
          inviteId: _inviteId,
          publicKey: account.publicKey,
        );
      } finally {
        ModalLoadingRoute.dismiss(context);
      }

      if (result?.signer != null) {
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

      final error = result?.error;
      if (error != null) {
        await PwDialog.showError(
          context,
          message: error,
        );
      }
    }

    return multiAccount;
  }
}

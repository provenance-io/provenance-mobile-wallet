import 'package:provenance_wallet/screens/multi_sig/multi_sig_invite_review_flow.dart';
import 'package:provenance_wallet/services/models/account.dart';

class MultiSigInviteReviewFlowBloc {
  MultiSigInviteReviewFlowBloc({
    required MultiSigInviteReviewFlowNavigator navigator,
  }) : _navigator = navigator;

  final MultiSigInviteReviewFlowNavigator _navigator;

  void submitChooseAccount() {
    _navigator.showChooseAccount();
  }

  Future<void> submitCreateNewAccount() async {
    final account = await _navigator.showCreateNewAccount();
    // TODO-Roy send request to server with public key

    _navigator.endFlow();
  }

  void submitLinkExistingAccount() {
    _navigator.showLinkExistingAccount();
  }

  void submitLinkedAccount(Account? account) {
    // TODO-Roy send request to server with public key

    _navigator.endFlow();
  }

  void submitMaybeLater() {
    _navigator.endFlow();
  }

  Future<void> declineInvite() async {
    _navigator.endFlow();
  }
}

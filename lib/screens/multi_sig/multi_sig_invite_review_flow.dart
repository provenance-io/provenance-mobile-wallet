import 'package:flutter/material.dart';
import 'package:provenance_wallet/clients/multi_sig_client/models/multi_sig_remote_account.dart';
import 'package:provenance_wallet/common/flow_base.dart';
import 'package:provenance_wallet/screens/account/basic_account_create_flow.dart';
import 'package:provenance_wallet/screens/add_account_origin.dart';
import 'package:provenance_wallet/screens/multi_sig/multi_sig_connect_screen.dart';
import 'package:provenance_wallet/screens/multi_sig/multi_sig_invite_review_create_or_link_screen.dart';
import 'package:provenance_wallet/screens/multi_sig/multi_sig_invite_review_details.dart';
import 'package:provenance_wallet/screens/multi_sig/multi_sig_invite_review_flow_bloc.dart';
import 'package:provenance_wallet/screens/multi_sig/multi_sig_invite_review_landing.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provider/provider.dart';

abstract class MultiSigInviteReviewFlowNavigator {
  MultiSigInviteReviewFlowNavigator._();

  void showReviewInvitationDetails();
  void showChooseAccount();
  Future<BasicAccount?> showCreateLinkedAccount();
  void showLinkExistingAccount();
  void endFlow(MultiSigAddResult? result);
}

class MultiSigInviteReviewFlow extends FlowBase {
  const MultiSigInviteReviewFlow({
    required this.inviteId,
    required this.multiSigRemoteAccount,
    Key? key,
  }) : super(key: key);

  final String inviteId;
  final MultiSigRemoteAccount multiSigRemoteAccount;

  @override
  State<StatefulWidget> createState() => MultiSigInviteReviewFlowState();
}

class MultiSigInviteReviewFlowState
    extends FlowBaseState<MultiSigInviteReviewFlow>
    implements MultiSigInviteReviewFlowNavigator {
  late final _bloc = MultiSigInviteReviewFlowBloc(
    inviteId: widget.inviteId,
    remoteAccount: widget.multiSigRemoteAccount,
    navigator: this,
  );

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: _bloc,
      child: super.build(context),
    );
  }

  @override
  Widget createStartPage() => MultiSigInviteReviewLanding(
        name: widget.multiSigRemoteAccount.name,
      );

  @override
  void showReviewInvitationDetails() {
    showPage(
      (context) => MultiSigInviteReviewDetails(
        name: widget.multiSigRemoteAccount.name,
        cosignerCount: widget.multiSigRemoteAccount.signers.length,
        signaturesRequired: widget.multiSigRemoteAccount.signersRequired,
      ),
    );
  }

  @override
  void showChooseAccount() {
    showPage(
      (context) => MultiSigInviteReviewCreateOrLinkScreen(),
    );
  }

  @override
  void endFlow(MultiSigAddResult? result) {
    completeFlow(result);
  }

  @override
  Future<BasicAccount?> showCreateLinkedAccount() async {
    final account = await showPage<BasicAccount?>(
      (context) => BasicAccountCreateFlow(
        origin: AddAccountOrigin.accounts,
      ),
    );

    return account;
  }

  @override
  void showLinkExistingAccount() {
    showPage(
      (context) => MultiSigConnectScreen(
        bloc: _bloc,
      ),
    );
  }
}

class MultiSigAddResult {
  MultiSigAddResult([
    this.account,
  ]);

  final MultiAccount? account;
}

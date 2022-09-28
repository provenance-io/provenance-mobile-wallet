import 'package:flutter/material.dart';
import 'package:provenance_wallet/clients/multi_sig_client/models/multi_sig_remote_account.dart';
import 'package:provenance_wallet/common/flow_base.dart';
import 'package:provenance_wallet/screens/add_account_flow.dart';
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
  void endFlow(MultiAccount? account);
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
  @override
  Widget createStartPage() => Provider<MultiSigInviteReviewFlowBloc>(
        lazy: true,
        create: (context) {
          return MultiSigInviteReviewFlowBloc(
            inviteId: widget.inviteId,
            remoteAccount: widget.multiSigRemoteAccount,
            navigator: this,
          );
        },
        child: MultiSigInviteReviewLanding(
          name: widget.multiSigRemoteAccount.name,
        ),
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
  void endFlow(MultiAccount? account) {
    completeFlow(account);
  }

  @override
  Future<BasicAccount?> showCreateLinkedAccount() async {
    final account = await showPage<BasicAccount?>(
      (context) => AddAccountFlow(
        origin: AddAccountOrigin.accounts,
        includeMultiSig: false,
      ),
    );

    return account;
  }

  @override
  void showLinkExistingAccount() {
    showPage(
      (context) => MultiSigConnectScreen(
        onAccount: Provider.of<MultiSigInviteReviewFlowBloc>(context)
            .submitLinkedAccount,
        enableCreate: false,
      ),
    );
  }
}

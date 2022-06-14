import 'package:flutter/material.dart';
import 'package:provenance_wallet/common/flow_base.dart';
import 'package:provenance_wallet/screens/add_account_flow.dart';
import 'package:provenance_wallet/screens/add_account_origin.dart';
import 'package:provenance_wallet/screens/multi_sig/multi_sig_connect_screen.dart';
import 'package:provenance_wallet/screens/multi_sig/multi_sig_invite_review_create_or_link_screen.dart';
import 'package:provenance_wallet/screens/multi_sig/multi_sig_invite_review_details.dart';
import 'package:provenance_wallet/screens/multi_sig/multi_sig_invite_review_flow_bloc.dart';
import 'package:provenance_wallet/screens/multi_sig/multi_sig_invite_review_landing.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/util/get.dart';

abstract class MultiSigInviteReviewFlowNavigator {
  MultiSigInviteReviewFlowNavigator._();

  void showReviewInvitationDetails();
  void showChooseAccount();
  Future<Account?> showCreateNewAccount();
  void showLinkExistingAccount();
  void endFlow();
}

class MultiSigInviteReviewFlow extends FlowBase {
  const MultiSigInviteReviewFlow({
    required this.name,
    required this.cosignerCount,
    required this.signaturesRequired,
    Key? key,
  }) : super(key: key);

  final String name;
  final int cosignerCount;
  final int signaturesRequired;

  @override
  State<StatefulWidget> createState() => MultiSigInviteReviewFlowState();
}

class MultiSigInviteReviewFlowState
    extends FlowBaseState<MultiSigInviteReviewFlow>
    implements MultiSigInviteReviewFlowNavigator {
  late final MultiSigInviteReviewFlowBloc bloc;

  @override
  void initState() {
    super.initState();

    bloc = MultiSigInviteReviewFlowBloc(
      navigator: this,
    );

    get.registerSingleton<MultiSigInviteReviewFlowNavigator>(this);
    get.registerSingleton<MultiSigInviteReviewFlowBloc>(bloc);
  }

  @override
  void dispose() {
    super.dispose();

    get.unregister<MultiSigInviteReviewFlowNavigator>();
    get.unregister<MultiSigInviteReviewFlowBloc>();
  }

  @override
  Widget createStartPage() => MultiSigInviteReviewLanding(
        name: widget.name,
      );

  @override
  void showReviewInvitationDetails() {
    showPage(
      (context) => MultiSigInviteReviewDetails(
        name: widget.name,
        cosignerCount: widget.cosignerCount,
        signaturesRequired: widget.signaturesRequired,
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
  void endFlow() {
    completeFlow(null);
  }

  @override
  Future<Account?> showCreateNewAccount() async {
    final account = await showPage<Account?>(
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
        onAccount: bloc.submitLinkedAccount,
      ),
    );
  }
}

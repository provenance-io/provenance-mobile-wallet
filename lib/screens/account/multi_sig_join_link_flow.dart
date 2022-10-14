import 'package:provenance_wallet/clients/multi_sig_client/models/multi_sig_remote_account.dart';
import 'package:provenance_wallet/clients/multi_sig_client/multi_sig_client.dart';
import 'package:provenance_wallet/common/flow_base.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/extension/stream_controller.dart';
import 'package:provenance_wallet/screens/multi_sig/multi_sig_invite_review_flow.dart';
import 'package:provenance_wallet/screens/multi_sig/multi_sig_join_link_screen.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/invite_link_util.dart';
import 'package:rxdart/rxdart.dart';

class MultiSigJoinLinkFlow extends FlowBase {
  const MultiSigJoinLinkFlow({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => MultiSigJoinLinkFlowState();
}

class MultiSigJoinLinkFlowState extends FlowBaseState<MultiSigJoinLinkFlow>
    implements MultiSigJoinLinkFlowNavigator {
  late final _bloc = MultiSigJoinLinkFlowBloc(
    navigator: this,
  );

  @override
  Widget createStartPage() {
    return MultiSigJoinLinkScreen(
      bloc: _bloc,
    );
  }

  @override
  Future<MultiAccount?> showInviteReviewFlow({
    required String inviteId,
    required MultiSigRemoteAccount remoteAccount,
  }) {
    return showPage<MultiAccount?>((context) {
      return MultiSigInviteReviewFlow(
        inviteId: inviteId,
        multiSigRemoteAccount: remoteAccount,
      );
    });
  }

  @override
  void endFlow(MultiAccount? account) {
    completeFlow(account);
  }
}

abstract class MultiSigJoinLinkFlowNavigator {
  Future<MultiAccount?> showInviteReviewFlow({
    required String inviteId,
    required MultiSigRemoteAccount remoteAccount,
  });

  void endFlow(MultiAccount? account);
}

class MultiSigJoinLinkFlowBloc implements MultiSigJoinLinkBloc {
  MultiSigJoinLinkFlowBloc({
    required MultiSigJoinLinkFlowNavigator navigator,
  }) : _navigator = navigator;

  final MultiSigJoinLinkFlowNavigator _navigator;
  final _client = get<MultiSigClient>();
  final _multiSigInviteLinkError = PublishSubject<String?>();

  @override
  Stream<String?> get multiSigInviteLinkError => _multiSigInviteLinkError;

  @override
  Future<bool> submitMultiSigJoinLink(
    String multiSigInvalidLink,
    String link,
  ) async {
    var success = false;

    final redirectedLink = await tryFollowRedirect(link);
    if (redirectedLink != null) {
      final linkData = parseInviteLinkData(redirectedLink);
      if (linkData != null) {
        final remoteAccount = await _client.getAccountByInvite(
          inviteId: linkData.inviteId,
          coin: linkData.coin,
        );
        if (remoteAccount != null) {
          success = true;

          final account = await _navigator.showInviteReviewFlow(
            inviteId: linkData.inviteId,
            remoteAccount: remoteAccount,
          );

          _navigator.endFlow(account);
        }
      }
    }

    if (!success) {
      _multiSigInviteLinkError.tryAdd(
        multiSigInvalidLink,
      );
    }

    return success;
  }
}

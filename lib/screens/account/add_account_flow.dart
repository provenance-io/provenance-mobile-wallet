import 'package:flutter/widgets.dart';
import 'package:provenance_wallet/clients/multi_sig_client/models/multi_sig_remote_account.dart';
import 'package:provenance_wallet/clients/multi_sig_client/multi_sig_client.dart';
import 'package:provenance_wallet/common/flow_base.dart';
import 'package:provenance_wallet/common/widgets/modal_loading.dart';
import 'package:provenance_wallet/screens/account_type_screen.dart';
import 'package:provenance_wallet/screens/add_account_origin.dart';
import 'package:provenance_wallet/screens/multi_sig/multi_sig_add_kind.dart';
import 'package:provenance_wallet/screens/multi_sig/multi_sig_create_or_join_screen.dart';
import 'package:provenance_wallet/screens/multi_sig/multi_sig_invite_review_flow.dart';
import 'package:provenance_wallet/screens/multi_sig/multi_sig_join_link_screen.dart';
import 'package:provenance_wallet/screens/qr_code_scanner.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/invite_link_util.dart';

import 'basic_account_create_flow.dart';
import 'basic_account_recover_flow.dart';
import 'multi_sig_account_create_flow.dart';
import 'multi_sig_recover_flow.dart';

class AddAccountFlow extends FlowBase {
  const AddAccountFlow({
    required AddAccountMethod method,
    required AddAccountOrigin origin,
    Key? key,
  })  : _method = method,
        _origin = origin,
        super(key: key);

  final AddAccountMethod _method;
  final AddAccountOrigin _origin;

  @override
  State<StatefulWidget> createState() => AddAccountFlowState();
}

class AddAccountFlowState extends FlowBaseState<AddAccountFlow>
    implements AddAccountFlowNavigator {
  late final _bloc = AddAccountFlowBloc(
    method: widget._method,
    origin: widget._origin,
    navigator: this,
  );

  @override
  Widget createStartPage() => AccountTypeScreen(
        bloc: _bloc,
      );

  @override
  Future<BasicAccount?> showBasicAccountCreate() async {
    return showPage(
      (context) => BasicAccountCreateFlow(
        origin: _bloc.origin,
      ),
    );
  }

  @override
  Future<BasicAccount?> showBasicAccountRecover() async {
    return showPage(
      (context) => BasicAccountRecoverFlow(
        origin: _bloc.origin,
      ),
    );
  }

  @override
  Future<void> showMultiSigAccountCreate() async {
    return showPage(
      (context) => MultiSigCreateOrJoinScreen(
        bloc: _bloc,
        addKinds: const {
          MultiSigAddKind.create,
          MultiSigAddKind.join,
          MultiSigAddKind.link,
        },
      ),
    );
  }

  @override
  Future<void> showMultiSigAccountRecover() async {
    return showPage(
      (context) => MultiSigCreateOrJoinScreen(
        bloc: _bloc,
        addKinds: const {
          MultiSigAddKind.recover,
          MultiSigAddKind.join,
          MultiSigAddKind.link,
        },
      ),
    );
  }

  @override
  void showMultiSigAddKind(MultiSigAddKind kind) async {
    switch (kind) {
      case MultiSigAddKind.create:
        final account = await showPage(
          (context) => MultiSigAccountCreateFlow(),
        );

        if (account != null) {
          _bloc.submitMultiSigAccount(account);
        }
        break;
      case MultiSigAddKind.recover:
        final account = await showPage(
          (context) => MultiSigRecoverFlow(),
        );

        if (account != null) {
          _bloc.submitMultiSigAccount(account);
        }
        break;
      case MultiSigAddKind.join:
        final link = await showPage<String>(
          (context) => QRCodeScanner(
            isValidCallback: (e) async => parseInviteLinkData(e) != null,
          ),
        );
        _bloc.submitMultiSigJoinLink(
          context,
          link,
        );

        break;
      case MultiSigAddKind.link:
        showPage<String>(
          (context) => MultiSigJoinLinkScreen(
            onSubmit: _bloc.submitMultiSigJoinLink,
          ),
        );

        break;
    }
  }

  @override
  Future<MultiSigAddResult?> showInviteReviewFlow({
    required String inviteId,
    required MultiSigRemoteAccount remoteAccount,
  }) {
    return showPage<MultiSigAddResult>((context) {
      return MultiSigInviteReviewFlow(
        inviteId: inviteId,
        multiSigRemoteAccount: remoteAccount,
      );
    });
  }

  @override
  void endFlow(Account? account) {
    completeFlow(account);
  }
}

abstract class AddAccountFlowNavigator {
  Future<BasicAccount?> showBasicAccountCreate();
  Future<BasicAccount?> showBasicAccountRecover();
  Future<void> showMultiSigAccountCreate();
  Future<void> showMultiSigAccountRecover();
  void showMultiSigAddKind(MultiSigAddKind kind);
  Future<MultiSigAddResult?> showInviteReviewFlow({
    required String inviteId,
    required MultiSigRemoteAccount remoteAccount,
  });
  void endFlow(Account? account);
}

class AddAccountFlowBloc implements AccountTypeBloc, MultiSigCreateOrJoinBloc {
  AddAccountFlowBloc({
    required this.method,
    required this.origin,
    required AddAccountFlowNavigator navigator,
  }) : _navigator = navigator;

  final _client = get<MultiSigClient>();
  final AddAccountFlowNavigator _navigator;

  final AddAccountMethod method;
  final AddAccountOrigin origin;

  Account? _account;

  @override
  Future<void> submitBasic() async {
    switch (method) {
      case AddAccountMethod.create:
        _account = await _navigator.showBasicAccountCreate();
        break;
      case AddAccountMethod.recover:
        _account = await _navigator.showBasicAccountRecover();
        break;
    }

    if (_account != null) {
      _navigator.endFlow(_account);
    }
  }

  @override
  void submitMultiSig() {
    switch (method) {
      case AddAccountMethod.create:
        _navigator.showMultiSigAccountCreate();
        break;
      case AddAccountMethod.recover:
        _navigator.showMultiSigAccountRecover();
        break;
    }
  }

  @override
  void submitMultiSigCreateOrJoin(MultiSigAddKind kind) {
    _navigator.showMultiSigAddKind(kind);
  }

  Future<void> submitMultiSigAccount(MultiAccount? account) async {
    _navigator.endFlow(account);
  }

  Future<bool> submitMultiSigJoinLink(
    BuildContext context,
    String? link,
  ) async {
    var success = false;

    final redirectedLink = await tryFollowRedirect(link);
    if (redirectedLink != null) {
      final linkData = parseInviteLinkData(redirectedLink);
      if (linkData != null) {
        MultiSigRemoteAccount? remoteAccount;

        try {
          remoteAccount = await _client.getAccountByInvite(
            inviteId: linkData.inviteId,
            coin: linkData.coin,
          );
        } finally {
          ModalLoadingRoute.dismiss(context);
        }

        if (remoteAccount != null) {
          success = true;

          final result = await _navigator.showInviteReviewFlow(
            inviteId: linkData.inviteId,
            remoteAccount: remoteAccount,
          );

          if (result != null) {
            _navigator.endFlow(result.account);
          }
        }
      }
    }

    return success;
  }
}

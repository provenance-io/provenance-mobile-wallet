import 'package:flutter/widgets.dart';
import 'package:provenance_wallet/common/flow_base.dart';
import 'package:provenance_wallet/screens/account_type_screen.dart';
import 'package:provenance_wallet/screens/add_account_origin.dart';
import 'package:provenance_wallet/screens/multi_sig/multi_sig_add_kind.dart';
import 'package:provenance_wallet/screens/multi_sig/multi_sig_create_or_join_screen.dart';
import 'package:provenance_wallet/services/models/account.dart';

import 'basic_account_create_flow.dart';
import 'basic_account_recover_flow.dart';
import 'multi_sig_account_create_flow.dart';
import 'multi_sig_join_link_flow.dart';
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
  Future<MultiAccount?> showMultiSigAddKind(MultiSigAddKind kind) async {
    MultiAccount? account;
    switch (kind) {
      case MultiSigAddKind.create:
        account = await showPage(
          (context) => MultiSigAccountCreateFlow(),
        );
        break;
      case MultiSigAddKind.join:
        account = await showPage(
          (context) => MultiSigJoinLinkFlow(),
        );
        break;
      case MultiSigAddKind.link:
        account = await showPage(
          (context) => MultiSigJoinLinkFlow(),
        );
        break;
      case MultiSigAddKind.recover:
        account = await showPage(
          (context) => MultiSigRecoverFlow(),
        );
        break;
    }

    return account;
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
  Future<MultiAccount?> showMultiSigAddKind(MultiSigAddKind kind);
  void endFlow(Account? account);
}

class AddAccountFlowBloc implements AccountTypeBloc, MultiSigCreateOrJoinBloc {
  AddAccountFlowBloc({
    required this.method,
    required this.origin,
    required AddAccountFlowNavigator navigator,
  }) : _navigator = navigator;

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
  Future<void> submitMultiSigCreateOrJoin(MultiSigAddKind kind) async {
    final account = await _navigator.showMultiSigAddKind(kind);
    if (account != null) {
      _navigator.endFlow(_account);
    }
  }
}

import 'package:provenance_wallet/clients/multi_sig_client/models/multi_sig_remote_account.dart';
import 'package:provenance_wallet/common/flow_base.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/modal_loading.dart';
import 'package:provenance_wallet/screens/multi_sig/multi_sig_recover_screen.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/util/get.dart';

class MultiSigRecoverFlow extends FlowBase {
  const MultiSigRecoverFlow({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => MultiSigRecoverFlowState();
}

class MultiSigRecoverFlowState extends FlowBaseState<MultiSigRecoverFlow>
    implements MultiSigRecoverFlowNavigator {
  late final _bloc = MultiSigRecoverFlowBloc(
    navigator: this,
  );

  @override
  Widget createStartPage() {
    return MultiSigRecoverScreen(
      bloc: _bloc,
    );
  }

  @override
  void endFlow(MultiAccount? account) {
    completeFlow(account);
  }
}

abstract class MultiSigRecoverFlowNavigator {
  void endFlow(MultiAccount? account);
}

class MultiSigRecoverFlowBloc implements MultiSigRecoverBloc {
  MultiSigRecoverFlowBloc({required MultiSigRecoverFlowNavigator navigator})
      : _navigator = navigator;

  final MultiSigRecoverFlowNavigator _navigator;
  final _accountService = get<AccountService>();

  @override
  Future<void> submitRecoverFromAccount({
    required BuildContext context,
    required MultiSigRemoteAccount account,
    required BasicAccount linkedAccount,
  }) async {
    ModalLoadingRoute.showLoading(context);

    MultiAccount? multiAccount;

    try {
      multiAccount = await _accountService.addMultiAccount(
        name: account.name,
        coin: account.coin,
        linkedAccountId: linkedAccount.id,
        remoteId: account.remoteId,
        cosignerCount: account.signers.length,
        signaturesRequired: account.signersRequired,
        inviteIds: account.signers.map((e) => e.inviteId).toList(),
        signers: account.signers,
      );
    } finally {
      ModalLoadingRoute.dismiss(context);
    }

    _navigator.endFlow(multiAccount);
  }
}

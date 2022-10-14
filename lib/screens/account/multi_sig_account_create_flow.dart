import 'package:provenance_wallet/clients/multi_sig_client/multi_sig_client.dart';
import 'package:provenance_wallet/common/flow_base.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/modal_loading.dart';
import 'package:provenance_wallet/screens/account_name_screen.dart';
import 'package:provenance_wallet/screens/count.dart';
import 'package:provenance_wallet/screens/field_mode.dart';
import 'package:provenance_wallet/screens/multi_sig/multi_sig_confirm_screen.dart';
import 'package:provenance_wallet/screens/multi_sig/multi_sig_connect_screen.dart';
import 'package:provenance_wallet/screens/multi_sig/multi_sig_count_screen.dart';
import 'package:provenance_wallet/screens/multi_sig/multi_sig_creation_status.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:rxdart/rxdart.dart';

class MultiSigAccountCreateFlow extends FlowBase {
  const MultiSigAccountCreateFlow({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => MultiSigAccountCreateFlowState();
}

class MultiSigAccountCreateFlowState
    extends FlowBaseState<MultiSigAccountCreateFlow>
    implements MultiSigAccountCreateFlowNavigator {
  late final _bloc = MultiSigAccountCreateFlowBloc(
    navigator: this,
  );

  @override
  Widget createStartPage() {
    return MultiSigConnectScreen(
      bloc: _bloc,
    );
  }

  @override
  void showMultiSigAccountName() {
    showPage(
      (context) => AccountNameScreen(
        message: Strings.of(context).accountNameMultiSigMessage,
        mode: FieldMode.initial,
        leadingIcon: PwIcons.back,
        bloc: _bloc,
        popOnSubmit: false,
      ),
    );
  }

  @override
  void showMultiSigCosigners(FieldMode mode,
      [int? currentStep, int? totalSteps]) {
    showPage(
      (context) => MultiSigCountScreen.cosigners(
        title: Strings.of(context).multiSigCosignersTitle,
        message: Strings.of(context).multiSigCosignersMessage,
        description: Strings.of(context).multiSigCosignersDescription,
        bloc: _bloc,
        mode: mode,
        currentStep: currentStep,
        totalSteps: totalSteps,
      ),
    );
  }

  @override
  void showMultiSigSignatures(FieldMode mode) {
    showPage(
      (context) => MultiSigCountScreen.signatures(
        title: Strings.of(context).multiSigSignaturesTitle,
        message: Strings.of(context).multiSigSignaturesMessage,
        description: Strings.of(context).multiSigSignaturesDescription,
        bloc: _bloc,
        mode: mode,
      ),
    );
  }

  @override
  void showMultiSigConfirm() {
    showPage(
      (context) => MultiSigConfirmScreen(
        bloc: _bloc,
      ),
    );
  }

  @override
  void showMultiSigCreationStatus(MultiAccount account) {
    showPage(
      (context) => MultiSigCreationStatus(
        accountId: account.id,
        onDone: _bloc.submitMultiSigStatusDone,
      ),
    );
  }

  @override
  void endFlow(MultiAccount? account) {
    completeFlow(account);
  }
}

abstract class MultiSigAccountCreateFlowNavigator {
  void showMultiSigAccountName();
  void showMultiSigCosigners(FieldMode mode);
  void showMultiSigSignatures(FieldMode mode);
  void showMultiSigConfirm();
  void showMultiSigCreationStatus(MultiAccount account);
  void endFlow(MultiAccount? account);
  void back<T>([T? value]);
}

class MultiSigAccountCreateFlowBloc
    implements
        MultiSigConnectBloc,
        AccountNameBloc,
        MultiSigCountBloc,
        MultiSigConfirmBloc {
  MultiSigAccountCreateFlowBloc({
    required MultiSigAccountCreateFlowNavigator navigator,
  }) : _navigator = navigator;

  final MultiSigAccountCreateFlowNavigator _navigator;
  final _accountService = get<AccountService>();
  final _multiSigClient = get<MultiSigClient>();

  final _name = BehaviorSubject.seeded('', sync: true);
  final _cosignerCount = BehaviorSubject.seeded(
    Count(
      value: 1,
      min: 1,
      max: 10,
    ),
  );
  final _signatureCount = BehaviorSubject.seeded(
    Count(
      value: 1,
      min: 1,
      max: 1,
    ),
  );
  BasicAccount? _linkedAccount;
  MultiAccount? _multiSigAccount;

  @override
  ValueStream<String> get name => _name;

  @override
  ValueStream<Count> get cosignerCount => _cosignerCount;

  @override
  ValueStream<Count> get signatureCount => _signatureCount;

  @override
  void submitMultiSigConnect(BuildContext context, BasicAccount account) {
    _linkedAccount = account;

    _navigator.showMultiSigAccountName();
  }

  @override
  void submitName(String name, FieldMode mode) {
    _name.add(name);

    switch (mode) {
      case FieldMode.initial:
        _navigator.showMultiSigCosigners(FieldMode.initial);
        break;
      case FieldMode.edit:
        _navigator.back();
        break;
    }
  }

  @override
  void submitMultiSigCosigners(int count) {
    _setCosignerCount(count);

    _navigator.showMultiSigSignatures(FieldMode.initial);
  }

  @override
  void submitMultiSigSignatures(int count) {
    _setSignatureCount(count);

    _navigator.showMultiSigConfirm();
  }

  @override
  void setCosignerCount(int count) {
    _setCosignerCount(count);

    _navigator.back();
  }

  @override
  void setSignatureCount(int count) {
    _setSignatureCount(count);

    _navigator.back();
  }

  @override
  Future<void> submitMultiSigConfirm(BuildContext context) async {
    ModalLoadingRoute.showLoading(context);

    final registration = await _multiSigClient.create(
      name: _name.value,
      publicKey: _linkedAccount!.publicKey,
      cosignerCount: _cosignerCount.value.value,
      threshold: _signatureCount.value.value,
    );

    if (registration != null) {
      final account = await _accountService.addMultiAccount(
        name: _name.value,
        coin: _linkedAccount!.coin,
        remoteId: registration.remoteId,
        inviteIds: registration.signers.map((e) => e.inviteId).toList(),
        linkedAccountId: _linkedAccount!.id,
        cosignerCount: _cosignerCount.value.value,
        signaturesRequired: _signatureCount.value.value,
      );

      _multiSigAccount = account;
    }

    ModalLoadingRoute.dismiss(context);

    // TODO-Roy: If a multi-sig was the first account added (along with a recovered basic account), then we get left at the "Add Account" page.
    // Need to re-check local auth?
    if (_multiSigAccount != null) {
      _navigator.showMultiSigCreationStatus(_multiSigAccount!);
    }
  }

  void submitMultiSigStatusDone() {
    _navigator.endFlow(_multiSigAccount);
  }

  void _setCosignerCount(int count) {
    int? min;
    int? max;

    final current = _cosignerCount.value;
    min = current.min;
    max = current.max;

    _cosignerCount.value = Count(
      value: count,
      min: min,
      max: max,
    );

    final signatures = _signatureCount.value;
    var signaturesValue = signatures.value;
    if (signaturesValue > count) {
      signaturesValue = count;
    }

    _signatureCount.value = Count(
      value: signaturesValue,
      min: signatures.min,
      max: count,
    );
  }

  void _setSignatureCount(int count) {
    int? min;
    int? max;

    final current = _signatureCount.value;
    min = current.min;
    max = current.max;

    _signatureCount.value = Count(
      value: count,
      min: min,
      max: max,
    );
  }
}

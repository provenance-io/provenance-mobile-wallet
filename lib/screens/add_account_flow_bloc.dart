import 'package:get_it/get_it.dart';
import 'package:prov_wallet_flutter/prov_wallet_flutter.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/chain_id.dart';
import 'package:provenance_wallet/common/enum/account_add_kind.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/modal_loading.dart';
import 'package:provenance_wallet/screens/add_account_flow.dart';
import 'package:provenance_wallet/screens/add_account_origin.dart';
import 'package:provenance_wallet/screens/multi_sig/multi_sig_add_kind.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/account_service/account_storage_service_core.dart';
import 'package:provenance_wallet/services/key_value_service/key_value_service.dart';
import 'package:provenance_wallet/services/models/account_details.dart';
import 'package:provenance_wallet/services/multi_sig_service/multi_sig_service.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/local_auth_helper.dart';
import 'package:rxdart/rxdart.dart';

enum AddAccountScreen {
  accountType,
  accountName,
  recoverAccount,
  createPassphrase,
  recoveryWords,
  recoveryWordsConfirm,
  backupComplete,
  createPin,
  confirmPin,
  enableFaceId,
  accountSetupConfirmation,
  recoverPassphraseEntry,
  // multi
  multiSigCreateOrJoin,
  multiSigConnect,
  multiSigAccountName,
  multiSigCosigners,
  multiSigSignatures,
  multiSigConfirm,
  multiSigCreationStatus,
}

const _flowCreateSingle = [
  AddAccountScreen.accountType,
  AddAccountScreen.accountName,
  AddAccountScreen.createPassphrase,
  AddAccountScreen.recoveryWords,
  AddAccountScreen.recoveryWordsConfirm,
  AddAccountScreen.backupComplete,
  AddAccountScreen.accountSetupConfirmation,
];

const _flowCreateSingleInitial = [
  AddAccountScreen.accountType,
  AddAccountScreen.accountName,
  AddAccountScreen.createPassphrase,
  AddAccountScreen.recoveryWords,
  AddAccountScreen.recoveryWordsConfirm,
  AddAccountScreen.backupComplete,
  AddAccountScreen.createPin,
  AddAccountScreen.confirmPin,
  AddAccountScreen.enableFaceId,
  AddAccountScreen.accountSetupConfirmation,
];

const _flowMultiSigCreateOrJoin = [
  AddAccountScreen.accountType,
  AddAccountScreen.multiSigCreateOrJoin,
];

const _flowMultiSigCreate = [
  AddAccountScreen.multiSigCreateOrJoin,
  AddAccountScreen.multiSigConnect,
  AddAccountScreen.multiSigAccountName,
  AddAccountScreen.multiSigCosigners,
  AddAccountScreen.multiSigSignatures,
  AddAccountScreen.multiSigConfirm,
  AddAccountScreen.multiSigCreationStatus,
];

const _flowRecover = [
  AddAccountScreen.accountType,
  AddAccountScreen.accountName,
  AddAccountScreen.recoverAccount,
  AddAccountScreen.recoverPassphraseEntry,
];

const _flowRecoverInitial = [
  AddAccountScreen.accountType,
  AddAccountScreen.accountName,
  AddAccountScreen.recoverAccount,
  AddAccountScreen.recoverPassphraseEntry,
  AddAccountScreen.createPin,
  AddAccountScreen.confirmPin,
  AddAccountScreen.enableFaceId,
  AddAccountScreen.accountSetupConfirmation,
];

class AddAccountFlowBloc implements Disposable {
  AddAccountFlowBloc({
    required AddAccountFlowNavigator navigator,
    required AddAccountOrigin origin,
  })  : _navigator = navigator,
        _origin = origin;

  final AddAccountFlowNavigator _navigator;
  final AddAccountOrigin _origin;
  final _accountService = get<AccountService>();
  final _keyValueService = get<KeyValueService>();

  final _name = BehaviorSubject<String>();
  final _multiSigName = BehaviorSubject<String>();
  final _multiSigCosignerCount = BehaviorSubject.seeded(
    Count(
      value: 1,
      min: 1,
      max: 10,
    ),
  );
  final _multiSigSignatureCount = BehaviorSubject.seeded(
    Count(
      value: 1,
      min: 1,
      max: 1,
    ),
  );

  ValueStream<String> get name => _name;
  ValueStream<String> get multiSigName => _multiSigName;
  ValueStream<Count> get multiSigCosignerCount => _multiSigCosignerCount;
  ValueStream<Count> get multiSigSignatureCount => _multiSigSignatureCount;

  BiometryType get biometryType => _biometryType!;

  AccountAddKind get addKind => _addKind!;
  List<String> get words => _words;
  List<int> get pin => _pin;

  var _words = <String>[];
  var _pin = <int>[];
  var _flow = <AddAccountScreen>[];

  AccountAddKind? _addKind;

  BiometryType? _biometryType;
  AccountDetails? _multiSigIndividualAccount;

  @override
  void onDispose() {
    _name.close();
    _multiSigName.close();
    _multiSigCosignerCount.close();
    _multiSigSignatureCount.close();
  }

  void setMultiSigName(String name) {
    _multiSigName.value = name;
  }

  void setCosignerCount(int count) {
    int? min;
    int? max;

    final current = _multiSigCosignerCount.value;
    min = current.min;
    max = current.max;

    _multiSigCosignerCount.value = Count(
      value: count,
      min: min,
      max: max,
    );

    final signatures = _multiSigSignatureCount.value;
    var signaturesValue = signatures.value;
    if (signaturesValue > count) {
      signaturesValue = count;
    }

    _multiSigSignatureCount.value = Count(
      value: signaturesValue,
      min: signatures.min,
      max: count,
    );
  }

  void setSignatureCount(int count) {
    int? min;
    int? max;

    final current = _multiSigSignatureCount.value;
    min = current.min;
    max = current.max;

    _multiSigSignatureCount.value = Count(
      value: count,
      min: min,
      max: max,
    );
  }

  void _showNext(AddAccountScreen current) {
    final index = _flow.indexOf(current);
    if (index == -1) {
      throw "Flow doesn't contain screen: $current. $_flow";
    }
    final nextIndex = index + 1;
    if (_flow.length > nextIndex) {
      _showScreen(
        screen: _flow[nextIndex],
        currentStep: nextIndex,
        totalSteps: _flow.length - 1,
      );
    } else {
      _navigator.endFlow();
    }
  }

  void _showScreen({
    required AddAccountScreen screen,
    required int currentStep,
    required int totalSteps,
  }) {
    switch (screen) {
      case AddAccountScreen.accountType:
        _navigator.showAccountType();
        break;
      case AddAccountScreen.accountName:
        _navigator.showAccountName(currentStep, totalSteps);
        break;
      case AddAccountScreen.recoverAccount:
        _navigator.showRecoverAccount(currentStep, totalSteps);
        break;
      case AddAccountScreen.createPassphrase:
        _navigator.showCreatePassphrase(currentStep, totalSteps);
        break;
      case AddAccountScreen.recoveryWords:
        _navigator.showRecoveryWords(currentStep, totalSteps);
        break;
      case AddAccountScreen.recoveryWordsConfirm:
        _navigator.showRecoveryWordsConfirm(currentStep, totalSteps);
        break;
      case AddAccountScreen.backupComplete:
        _navigator.showBackupComplete(currentStep, totalSteps);
        break;
      case AddAccountScreen.createPin:
        _navigator.showCreatePin(currentStep, totalSteps);
        break;
      case AddAccountScreen.confirmPin:
        _navigator.showConfirmPin(currentStep, totalSteps);
        break;
      case AddAccountScreen.enableFaceId:
        _navigator.showEnableFaceId(currentStep, totalSteps);
        break;
      case AddAccountScreen.accountSetupConfirmation:
        _navigator.showAccountSetupConfirmation();
        break;
      case AddAccountScreen.recoverPassphraseEntry:
        _navigator.showRecoverPassphraseEntry(currentStep, totalSteps);
        break;
      case AddAccountScreen.multiSigCreateOrJoin:
        _navigator.showMultiSigCreateOrJoin();
        break;
      case AddAccountScreen.multiSigConnect:
        _navigator.showMultiSigConnect(currentStep, totalSteps);
        break;
      case AddAccountScreen.multiSigAccountName:
        _navigator.showMultiSigAccountName(currentStep, totalSteps);
        break;
      case AddAccountScreen.multiSigCosigners:
        _navigator.showMultiSigCosigners(
            FieldMode.initial, currentStep, totalSteps);
        break;
      case AddAccountScreen.multiSigSignatures:
        _navigator.showMultiSigSignatures(
            FieldMode.initial, currentStep, totalSteps);
        break;
      case AddAccountScreen.multiSigConfirm:
        _navigator.showMultiSigConfirm(currentStep, totalSteps);
        break;
      case AddAccountScreen.multiSigCreationStatus:
        _navigator.showMultiSigCreationStatus();
        break;
    }
  }

  void submitAccountType(AccountAddKind addKind) {
    switch (addKind) {
      case AccountAddKind.createSingle:
        switch (_origin) {
          case AddAccountOrigin.accounts:
            _flow = _flowCreateSingle;
            break;
          case AddAccountOrigin.landing:
            _flow = _flowCreateSingleInitial;
            break;
        }
        break;
      case AccountAddKind.createMulti:
        _flow = _flowMultiSigCreateOrJoin;
        break;
      case AccountAddKind.recover:
        switch (_origin) {
          case AddAccountOrigin.accounts:
            _flow = _flowRecover;
            break;
          case AddAccountOrigin.landing:
            _flow = _flowRecoverInitial;
            break;
        }
        break;
    }

    _showNext(AddAccountScreen.accountType);
  }

  void submitAccountName(String name) {
    _name.value = name;

    _showNext(AddAccountScreen.accountName);
  }

  void submitCreatePassphrase() {
    _showNext(AddAccountScreen.createPassphrase);
  }

  void submitRecoveryWords(List<String> words) {
    _words = words;

    _showNext(AddAccountScreen.recoveryWords);
  }

  void submitRecoveryWordsConfirm() {
    _showNext(AddAccountScreen.recoveryWordsConfirm);
  }

  Future<void> submitBackupComplete(BuildContext context) async {
    if (_origin == AddAccountOrigin.accounts) {
      ModalLoadingRoute.showLoading(
        "",
        context,
      );

      final coin = await _defaultCoin();

      await get<AccountService>().addAccount(
        phrase: words,
        name: name.value,
        coin: coin,
      );

      ModalLoadingRoute.dismiss(context);
    }

    _showNext(AddAccountScreen.backupComplete);
  }

  void submitCreatePin(List<int> pin) {
    _pin = pin;

    _showNext(AddAccountScreen.createPin);
  }

  Future<void> submitConfirmPin() async {
    _biometryType = await get<CipherService>().getBiometryType();

    _showNext(AddAccountScreen.confirmPin);
  }

  Future<void> submitEnableFaceId({
    required BuildContext context,
    required bool useBiometry,
  }) async {
    ModalLoadingRoute.showLoading(
      "",
      context,
    );

    AccountDetails? details;

    final enrolled = await get<LocalAuthHelper>().enroll(
      _pin.join(),
      name.value,
      useBiometry,
      context,
    );

    if (enrolled) {
      final coin = await _defaultCoin();
      details = await get<AccountService>().addAccount(
        phrase: words,
        name: name.value,
        coin: coin,
      );
    }

    ModalLoadingRoute.dismiss(context);

    if (details != null) {
      _showNext(AddAccountScreen.enableFaceId);
    }
  }

  void submitRecoverAccount() {
    _showNext(AddAccountScreen.recoverAccount);
  }

  Future<void> submitRecoverPassphraseEntry(
      BuildContext context, List<String> words) async {
    if (_origin == AddAccountOrigin.accounts) {
      ModalLoadingRoute.showLoading(
        "",
        context,
      );

      final coin = await _defaultCoin();

      await get<AccountService>().addAccount(
        phrase: words,
        name: name.value,
        coin: coin,
      );

      ModalLoadingRoute.dismiss(context);
    }

    _showNext(AddAccountScreen.recoverPassphraseEntry);
  }

  void submitAccountSetupConfirmation() {
    _showNext(AddAccountScreen.accountSetupConfirmation);
  }

  void submitMultiSigCreateOrJoin(MultiSigAddKind kind) {
    switch (kind) {
      case MultiSigAddKind.create:
        _flow = _flowMultiSigCreate;
        break;
      case MultiSigAddKind.join:
        // TODO-Roy: Handle this case.
        throw 'Not Implemented';
    }

    _showNext(AddAccountScreen.multiSigCreateOrJoin);
  }

  void submitMultiSigConnect(AccountDetails? details) {
    _multiSigIndividualAccount = details;

    if (_multiSigIndividualAccount == null) {
      // TODO-Roy: Set _flow to a create flow
      throw 'Not Implemented';
    }

    _showNext(AddAccountScreen.multiSigConnect);
  }

  void submitMultiSigAccountName(String name) {
    _multiSigName.value = name;

    _showNext(AddAccountScreen.multiSigAccountName);
  }

  void submitMultiSigCosigners(int count) {
    setCosignerCount(count);

    _showNext(AddAccountScreen.multiSigCosigners);
  }

  void submitMultiSigSignatures(int count) {
    setSignatureCount(count);

    _showNext(AddAccountScreen.multiSigSignatures);
  }

  Future<void> submitMultiSigConfirm(BuildContext context) async {
    ModalLoadingRoute.showLoading('', context);

    final coin = await _defaultCoin();

    final id = await get<MultiSigService>().register(
      cosignerCount: _multiSigCosignerCount.value.value,
    );

    // TODO-ROY: need to store id so we can get the invite details

    await _accountService.addPendingAccount(
      name: _multiSigName.value,
      kind: AccountKind.multi,
      coin: coin,
    );

    ModalLoadingRoute.dismiss(context);

    _showNext(AddAccountScreen.multiSigConfirm);
  }

  Future<Coin> _defaultCoin() async {
    final chainId = await _keyValueService.getString(PrefKey.defaultChainId) ??
        ChainId.defaultChainId;
    final coin = ChainId.toCoin(chainId);

    return coin;
  }
}

enum FieldMode {
  initial,
  edit,
}

class Count {
  Count({
    required this.value,
    this.min,
    this.max,
  });

  final int value;
  final int? min;
  final int? max;
}

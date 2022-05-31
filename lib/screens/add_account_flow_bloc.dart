import 'package:prov_wallet_flutter/prov_wallet_flutter.dart';
import 'package:provenance_wallet/chain_id.dart';
import 'package:provenance_wallet/common/enum/account_add_kind.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/modal_loading.dart';
import 'package:provenance_wallet/screens/add_account_flow.dart';
import 'package:provenance_wallet/screens/add_account_origin.dart';
import 'package:provenance_wallet/screens/multi_sig/multi_sig_add_kind.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/key_value_service/key_value_service.dart';
import 'package:provenance_wallet/services/models/account_details.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/local_auth_helper.dart';

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

class AddAccountFlowBloc {
  AddAccountFlowBloc({
    required AddAccountFlowNavigator navigator,
    required AddAccountOrigin origin,
  })  : _navigator = navigator,
        _origin = origin;

  final AddAccountFlowNavigator _navigator;
  final AddAccountOrigin _origin;

  BiometryType get biometryType => _biometryType!;
  int get totalSteps => _flow.length - 1;

  String get name => _name!;
  AccountAddKind get addKind => _addKind!;
  AddAccountOrigin get origin => _origin;
  List<String> get words => _words;
  List<int> get pin => _pin;

  var _words = <String>[];
  var _pin = <int>[];
  var _flow = <AddAccountScreen>[];

  AccountAddKind? _addKind;
  String? _name;
  BiometryType? _biometryType;
  AccountDetails? _multiSigIndividualAccount;

  int getCurrentStep(AddAccountScreen current) {
    final index = _flow.indexOf(current);
    if (index == -1) {
      throw "Flow doesn't contain screen: $current";
    }

    return index;
  }

  void _showNext(AddAccountScreen current) {
    final index = _flow.indexOf(current);
    if (index == -1) {
      throw "Flow doesn't contain screen: $current";
    }
    final nextIndex = index + 1;
    if (_flow.length > nextIndex) {
      _showScreen(_flow[nextIndex]);
    } else {
      _navigator.endFlow();
    }
  }

  void _showScreen(AddAccountScreen screen) {
    switch (screen) {
      case AddAccountScreen.accountType:
        _navigator.showAccountType();
        break;
      case AddAccountScreen.accountName:
        _navigator.showAccountName();
        break;
      case AddAccountScreen.recoverAccount:
        _navigator.showRecoverAccount();
        break;
      case AddAccountScreen.createPassphrase:
        _navigator.showCreatePassphrase();
        break;
      case AddAccountScreen.recoveryWords:
        _navigator.showRecoveryWords();
        break;
      case AddAccountScreen.recoveryWordsConfirm:
        _navigator.showRecoveryWordsConfirm();
        break;
      case AddAccountScreen.backupComplete:
        _navigator.showBackupComplete();
        break;
      case AddAccountScreen.createPin:
        _navigator.showCreatePin();
        break;
      case AddAccountScreen.confirmPin:
        _navigator.showConfirmPin();
        break;
      case AddAccountScreen.enableFaceId:
        _navigator.showEnableFaceId();
        break;
      case AddAccountScreen.accountSetupConfirmation:
        _navigator.showAccountSetupConfirmation();
        break;
      case AddAccountScreen.recoverPassphraseEntry:
        _navigator.showRecoverPassphraseEntry();
        break;
      case AddAccountScreen.multiSigCreateOrJoin:
        _navigator.showMultiSigCreateOrJoin();
        break;
      case AddAccountScreen.multiSigConnect:
        _navigator.showMultiSigConnect();
        break;
      case AddAccountScreen.multiSigAccountName:
        _navigator.showMultiSigAccountName();
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
    _name = name;

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

      final chainId =
          await get<KeyValueService>().getString(PrefKey.defaultChainId) ??
              ChainId.defaultChainId;
      final coin = ChainId.toCoin(chainId);

      await get<AccountService>().addAccount(
        phrase: words,
        name: name,
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
      name,
      useBiometry,
      context,
    );

    if (enrolled) {
      final chainId =
          await get<KeyValueService>().getString(PrefKey.defaultChainId) ??
              ChainId.defaultChainId;
      final coin = ChainId.toCoin(chainId);
      details = await get<AccountService>().addAccount(
        phrase: words,
        name: name,
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

      final chainId = await get<KeyValueService>().getString(
            PrefKey.defaultChainId,
          ) ??
          ChainId.defaultChainId;
      final coin = ChainId.toCoin(chainId);

      await get<AccountService>().addAccount(
        phrase: words,
        name: name,
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
}

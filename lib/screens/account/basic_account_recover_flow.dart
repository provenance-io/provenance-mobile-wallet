import 'package:prov_wallet_flutter/prov_wallet_flutter.dart';
import 'package:provenance_wallet/common/flow_base.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/network.dart';
import 'package:provenance_wallet/screens/account_name_screen.dart';
import 'package:provenance_wallet/screens/account_setup_confirmation_screen.dart';
import 'package:provenance_wallet/screens/add_account_origin.dart';
import 'package:provenance_wallet/screens/enable_face_id_screen.dart';
import 'package:provenance_wallet/screens/field_mode.dart';
import 'package:provenance_wallet/screens/pin/confirm_pin.dart';
import 'package:provenance_wallet/screens/pin/create_pin.dart';
import 'package:provenance_wallet/screens/recover_account_screen.dart';
import 'package:provenance_wallet/screens/recover_passphrase_entry_screen/recover_passphrase_entry_screen.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/local_auth_helper.dart';
import 'package:provenance_wallet/util/logs/logging.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:rxdart/rxdart.dart';

class BasicAccountRecoverFlow extends FlowBase {
  const BasicAccountRecoverFlow({
    required AddAccountOrigin origin,
    Key? key,
  })  : _origin = origin,
        super(key: key);

  final AddAccountOrigin _origin;

  @override
  State<StatefulWidget> createState() => BasicAccountRecoverFlowState();
}

class BasicAccountRecoverFlowState
    extends FlowBaseState<BasicAccountRecoverFlow>
    implements BasicAccountRecoverFlowNavigator {
  late final _bloc = BasicAccountRecoverFlowBloc(
    origin: widget._origin,
    navigator: this,
  );

  @override
  Widget createStartPage() {
    return AccountNameScreen(
      bloc: _bloc,
      mode: FieldMode.initial,
      leadingIcon: PwIcons.back,
      message: Strings.of(context).accountNameMessage,
    );
  }

  @override
  void showRecoverAccount() {
    showPage(
      (context) => RecoverAccountScreen(
        bloc: _bloc,
      ),
    );
  }

  @override
  void showRecoverPassphraseEntry() {
    showPage(
      (context) => RecoverPassphraseEntryScreen(
        bloc: _bloc,
      ),
    );
  }

  @override
  void showCreatePin() {
    showPage(
      (context) => CreatePin(
        bloc: _bloc,
      ),
    );
  }

  @override
  void showConfirmPin() {
    showPage(
      (context) => ConfirmPin(
        bloc: _bloc,
      ),
    );
  }

  @override
  void showEnableFaceId() {
    showPage(
      (context) => EnableFaceIdScreen(
        bloc: _bloc,
      ),
    );
  }

  @override
  void showAccountSetupConfirmation() {
    showPage(
      (context) => AccountSetupConfirmationScreen(
        bloc: _bloc,
      ),
    );
  }

  @override
  void endFlow(BasicAccount? account) {
    completeFlow(account);
  }
}

abstract class BasicAccountRecoverFlowNavigator {
  void showRecoverAccount();
  void showRecoverPassphraseEntry();
  void showCreatePin();
  void showConfirmPin();
  void showEnableFaceId();
  void showAccountSetupConfirmation();
  void endFlow(BasicAccount? account);
  void back<T>([T? value]);
}

class BasicAccountRecoverFlowBloc
    implements
        AccountNameBloc,
        RecoverAccountBloc,
        RecoverPassphraseEntryBloc,
        CreatePinBloc,
        ConfirmPinBloc,
        EnableFaceIdBloc,
        AccountSetupConfirmationBloc {
  BasicAccountRecoverFlowBloc({
    required AddAccountOrigin origin,
    required BasicAccountRecoverFlowNavigator navigator,
  })  : _origin = origin,
        _navigator = navigator {
    _init();
  }

  final AddAccountOrigin _origin;
  final BasicAccountRecoverFlowNavigator _navigator;

  final _accountService = get<AccountService>();

  final _name = BehaviorSubject.seeded('', sync: true);

  final _biometryType = BehaviorSubject<BiometryType>();
  final _network = BehaviorSubject.seeded(Network.mainNet);

  var _recoveryWords = <String>[];
  var _pin = <int>[];
  BasicAccount? _account;

  @override
  List<int> get pin => _pin;

  @override
  ValueStream<BiometryType> get biometryType => _biometryType;

  @override
  ValueStream<String> get name => _name;

  @override
  ValueStream<Network> get network => _network;

  @override
  void submitName({
    required String name,
    required FieldMode mode,
    required Network network,
  }) {
    _name.add(name);

    _network.add(network);

    switch (mode) {
      case FieldMode.initial:
        _navigator.showRecoverAccount();
        break;
      case FieldMode.edit:
        _navigator.back();
        break;
    }
  }

  @override
  void submitRecoverAccount() {
    _navigator.showRecoverPassphraseEntry();
  }

  @override
  void submitRecoverPassphraseEntry(List<String> words) {
    _recoveryWords = words;

    switch (_origin) {
      case AddAccountOrigin.accounts:
        _addAccount();
        break;
      case AddAccountOrigin.landing:
        _navigator.showCreatePin();
        break;
    }
  }

  @override
  void submitCreatePin(List<int> digits) {
    _pin = digits;
    _navigator.showConfirmPin();
  }

  @override
  void submitConfirmPin() {
    _navigator.showEnableFaceId();
  }

  @override
  Future<void> submitEnableFaceId({
    required BuildContext context,
    required bool useBiometry,
  }) async {
    final enrolled = await get<LocalAuthHelper>().enroll(
      _pin.join(),
      name.value,
      useBiometry,
      context,
    );

    if (enrolled) {
      await _addAccount();
    } else {
      logError('Failed to enroll');
    }
  }

  @override
  void submitAccountSetupConfirmation() {
    _navigator.endFlow(_account);
  }

  Future<void> _init() async {
    final type = await get<CipherService>().getBiometryType();
    _biometryType.add(type);
  }

  Future<void> _addAccount() async {
    _account = await _accountService.addAccount(
      phrase: _recoveryWords,
      name: name.value,
      network: _network.value,
    );

    if (_account == null) {
      logError('Failed to add account');
    } else {
      _navigator.showAccountSetupConfirmation();
    }
  }
}

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:get_it/get_it.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/dialogs/error_dialog.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/local_auth_helper.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:rxdart/rxdart.dart';

abstract class ChangePinBlocNavigator {
  Future<void> confirmPin();
  Future<void> enableBiometrics();
  Future<void> pinUpdatedSuccessfully();
  Future<void> endFlow();
}

class ChangePinBloc extends Disposable {
  ChangePinBloc(
    String accountName,
    this._navigator,
  ) : _accountName = BehaviorSubject.seeded(accountName);
  final ChangePinBlocNavigator _navigator;
  final BehaviorSubject<String> _accountName;
  final BehaviorSubject<List<int>> _inputCode = BehaviorSubject.seeded([]);

  final _authHelper = get<LocalAuthHelper>();

  ValueStream<String> get accountName => _accountName.stream;
  ValueStream<List<int>> get inputCode => _inputCode.stream;

  @override
  FutureOr onDispose() {
    _accountName.close();
    _inputCode.close();
  }

  Future<void> confirmPin(List<int> inputCode) async {
    _inputCode.value = inputCode;
    _navigator.confirmPin();
  }

  Future<void> enableBiometrics(
    List<int> inputCode,
    BuildContext context,
  ) async {
    if (!ListEquality().equals(inputCode, _inputCode.value)) {
      await showDialog(
        useSafeArea: true,
        context: context,
        builder: (context) => ErrorDialog(
          error: Strings.yourPinDoesNotMatchPleaseTryAgain,
        ),
      );
    } else {
      _navigator.enableBiometrics();
    }
  }

  Future<void> enrollInBiometrics(
    BuildContext context,
    bool enroll,
  ) async {
    await _authHelper.enroll(
      _inputCode.value.join(" "),
      _accountName.value,
      enroll,
      context,
    );

    await _navigator.pinUpdatedSuccessfully();
  }

  Future<void> returnToProfile() async {
    _navigator.endFlow();
  }

  Future<void> doAuth(BuildContext context) async {
    final status = await _authHelper.auth(context);
    if (status == AuthStatus.unauthenticated) {
      returnToProfile();
    }
  }
}

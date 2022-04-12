import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:prov_wallet_flutter/prov_wallet_flutter.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/screens/pin/validate_pin.dart';
import 'package:provenance_wallet/services/wallet_service/wallet_service.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:rxdart/rxdart.dart';

enum AuthStatus {
  noAccount,
  noWallet,
  noLockScreen,
  authenticated,
  timedOut,
  unauthenticated,
}

class LocalAuthHelper with WidgetsBindingObserver implements Disposable {
  LocalAuthHelper() {
    WidgetsBinding.instance?.addObserver(this);
  }

  static const _inactivityTimeout = Duration(minutes: 2);
  final _cipherService = get<CipherService>();
  final _walletService = get<WalletService>();
  final _status = BehaviorSubject<AuthStatus>.seeded(AuthStatus.noAccount);
  Timer? _inactivityTimer;

  ValueStream<AuthStatus> get status => _status;

  void reset() {
    _status.value = AuthStatus.noAccount;
  }

  Future<bool> enroll(
    String code,
    String accountName,
    bool useBiometry,
    BuildContext context,
  ) async {
    var success = await _cipherService.setUseBiometry(useBiometry: useBiometry);
    if (success) {
      success = await _cipherService.setPin(code);
      _status.value = AuthStatus.authenticated;
    }

    return success;
  }

  Future<AuthStatus> auth(BuildContext context) async {
    await _init();
    final pin = await _cipherService.getPin();
    if (pin == null || pin.isEmpty) {
      const result = AuthStatus.noAccount;
      _status.value = result;

      return result;
    }

    var result = AuthStatus.unauthenticated;

    final useBiometry = await _cipherService.getUseBiometry() ?? false;
    if (useBiometry) {
      final success = await _cipherService.authenticateBiometry();
      result = success ? AuthStatus.authenticated : await _validatePin(context);
    } else {
      result = await _validatePin(context);
    }

    _status.value = result;

    return result;
  }

  @override
  FutureOr onDispose() {
    WidgetsBinding.instance?.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _cancelInactivityTimer();
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        _startInactivityTimer();
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  Future<void> _init() async {
    AuthStatus status;
    final lockScreenEnabled = await _cipherService.getLockScreenEnabled();
    if (!lockScreenEnabled) {
      status = AuthStatus.noLockScreen;
    } else {
      final code = await _cipherService.getPin();
      if (code == null || code.isEmpty) {
        status = AuthStatus.noAccount;
      } else {
        final wallets = await _walletService.getWallets();
        status =
            wallets.isEmpty ? AuthStatus.noWallet : AuthStatus.unauthenticated;
      }
    }

    _status.value = status;
  }

  Future<AuthStatus> _validatePin(BuildContext context) async {
    final code = await _cipherService.getPin();
    final success = await Navigator.of(context).push(
      ValidatePin(code: code?.split("").map((e) => int.parse(e)).toList())
          .route(),
    );

    var result = AuthStatus.unauthenticated;

    if (success == true) {
      result = AuthStatus.authenticated;
    }

    return result;
  }

  void _startInactivityTimer() {
    _inactivityTimer ??= Timer(_inactivityTimeout, () {
      _inactivityTimer = null;
      _cipherService.resetAuth();
      _status.value = AuthStatus.timedOut;
    });
  }

  void _cancelInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = null;
  }
}

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/services/connectivity/connectivity_service.dart';
import 'package:rxdart/rxdart.dart';

class DefaultConnectivityService extends ConnectivityService
    with WidgetsBindingObserver
    implements Disposable {
  DefaultConnectivityService() {
    WidgetsBinding.instance?.addObserver(this);
    _connectivity.onConnectivityChanged
        .listen(_connectivityChanged)
        .addTo(_subscriptions);
  }

  final _subscriptions = CompositeSubscription();
  final _connectivity = Connectivity();
  final _isConnected = BehaviorSubject<bool>(sync: false);

  @override
  ValueStream<bool> get isConnected => _isConnected.stream;

  @override
  FutureOr onDispose() {
    WidgetsBinding.instance?.removeObserver(this);
    _subscriptions.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _connectivity.checkConnectivity().then(_connectivityChanged);
    }
  }

  void _connectivityChanged(ConnectivityResult result) {
    // Note: When device is using VPN, connectivity status may still show wifi or mobile even when disconnected on iOS.
    _isConnected.value = result != ConnectivityResult.none;
  }
}

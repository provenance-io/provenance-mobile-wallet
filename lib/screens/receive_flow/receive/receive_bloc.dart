import 'dart:async';

import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:provenance_wallet/services/models/wallet_details.dart';

abstract class ReceiveNavigator {}

class ReceiveState {
  ReceiveState(this.walletAddress);

  final String walletAddress;
}

class ReceiveBloc implements Disposable {
  ReceiveBloc(this._walletDetails, this._navigator) {
    final state = ReceiveState(
      _walletDetails.address,
    );

    _streamController.add(state);
  }

  final WalletDetails _walletDetails;
  final ReceiveNavigator _navigator;
  final _streamController = StreamController<ReceiveState>();

  Stream<ReceiveState> get stream => _streamController.stream;

  @override
  FutureOr onDispose() {
    _streamController.close();
  }

  Future<void> copyAddressToClipboard() {
    return Clipboard.setData(ClipboardData(text: _walletDetails.address));
  }
}

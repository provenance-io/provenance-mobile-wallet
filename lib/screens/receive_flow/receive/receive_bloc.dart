import 'dart:async';

import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:provenance_wallet/services/models/account.dart';

abstract class ReceiveNavigator {}

class ReceiveState {
  ReceiveState(this.accountAddress);

  final String accountAddress;
}

class ReceiveBloc implements Disposable {
  ReceiveBloc(this._accountDetails) {
    final state = ReceiveState(
      _accountDetails.address,
    );

    _streamController.add(state);
  }

  final TransactableAccount _accountDetails;
  final _streamController = StreamController<ReceiveState>();

  Stream<ReceiveState> get stream => _streamController.stream;

  @override
  FutureOr onDispose() {
    _streamController.close();
  }

  Future<void> copyAddressToClipboard() {
    return Clipboard.setData(ClipboardData(text: _accountDetails.address));
  }
}

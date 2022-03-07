import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provenance_dart/wallet_connect.dart';
import 'package:provenance_wallet/services/asset_service/asset_service.dart';
import 'package:provenance_wallet/services/deep_link/deep_link_service.dart';
import 'package:provenance_wallet/services/models/asset.dart';
import 'package:provenance_wallet/services/models/transaction.dart';
import 'package:provenance_wallet/services/transaction_service/transaction_service.dart';
import 'package:rxdart/rxdart.dart';

class MockDeepLinkService implements DeepLinkService {
  MockDeepLinkService([this._link]);

  final ValueStream<Uri>? _link;

  @override
  ValueStream<Uri> get link => _link ?? BehaviorSubject();
}

class MockAssetService implements AssetService {
  MockAssetService([this._assets = const {}]);

  final Map<String, List<Asset>> _assets;

  @override
  Future<List<Asset>> getAssets(String provenanceAddresses) =>
      Future.value(_assets[provenanceAddresses] ?? []);
}

class MockTransactionService implements TransactionService {
  MockTransactionService([this._transactions = const {}]);

  final Map<String, List<Transaction>> _transactions;

  @override
  Future<List<Transaction>> getTransactions(String provenanceAddress) =>
      Future.value(_transactions[provenanceAddress] ?? []);
}

class MockWalletConnection extends ValueListenable<WalletConnectState>
    implements WalletConnection {
  MockWalletConnection(this.address);

  final _listeners = <VoidCallback>[];
  var _state = WalletConnectState.disconnected;

  @override
  final WalletConnectAddress address;

  @override
  WalletConnectState get value => _state;

  @override
  Future<void> connect(WalletConnectionDelegate delegate) async {
    _updateState(WalletConnectState.connecting);
    _updateState(WalletConnectState.connected);

    final client = ClientMeta(
      description: 'Test Description',
      url: address.bridge,
      name: 'Test Name',
    );

    delegate.onApproveSession(client, (accept) async {
      if (accept != null) {
        _updateState(WalletConnectState.connected);
      }
    });
  }

  @override
  Future<void> disconnect() async {
    _updateState(WalletConnectState.disconnected);
  }

  @override
  Future<void> dispose() async {
    return;
  }

  @override
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void _updateState(WalletConnectState state) {
    _state = state;
    for (final listener in _listeners) {
      listener();
    }
  }
}

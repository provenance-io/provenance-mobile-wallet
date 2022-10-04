import 'package:flutter_test/flutter_test.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/services/asset_client/asset_client.dart';
import 'package:provenance_wallet/services/deep_link/deep_link_service.dart';
import 'package:provenance_wallet/services/models/asset.dart';
import 'package:provenance_wallet/services/models/asset_graph_item.dart';
import 'package:provenance_wallet/services/models/send_transactions.dart';
import 'package:provenance_wallet/services/models/transaction.dart';
import 'package:provenance_wallet/services/transaction_client/transaction_client.dart';
import 'package:rxdart/rxdart.dart';

class MockDeepLinkService implements DeepLinkService {
  MockDeepLinkService([this._link]);

  final ValueStream<Uri>? _link;

  @override
  ValueStream<Uri> get link => _link ?? BehaviorSubject();
}

class MockAssetClient implements AssetClient {
  MockAssetClient([this._assets = const {}]);

  final Map<String, List<Asset>> _assets;

  @override
  Future<List<Asset>> getAssets(
    Coin coin,
    String provenanceAddresses,
  ) =>
      Future.value(_assets[provenanceAddresses] ?? []);

  @override
  Future<List<AssetGraphItem>> getAssetGraphingData(
    Coin coin,
    String assetType,
    GraphingDataValue value, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return [];
  }
}

class MockTransactionService implements TransactionClient {
  MockTransactionService([
    this._sendTransactions = const {},
    this._transactions = const {},
  ]);

  final Map<String, List<Transaction>> _transactions;
  final Map<String, List<SendTransaction>> _sendTransactions;

  @override
  Future<List<Transaction>> getTransactions(
    Coin coin,
    String provenanceAddress,
    int page,
  ) =>
      Future.value(_transactions[provenanceAddress] ?? []);

  @override
  Future<List<SendTransaction>> getSendTransactions(
    Coin coin,
    String provenanceAddress,
  ) =>
      Future.value(_sendTransactions[provenanceAddress] ?? []);
}
/*
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
  Future<void> connect(
    WalletConnectionDelegate delegate, [
    SessionRestoreData? restoreData,
  ]) async {
    _updateState(WalletConnectState.connecting);
    _updateState(WalletConnectState.connected);

    if (restoreData == null) {
      final client = ClientMeta(
        description: 'Test Description',
        url: address.bridge,
        name: 'Test Name',
      );

      const peerId = 'PeerId';
      const remotePeerId = 'RemotePeerId';

      final data = SessionRequestData(
        peerId,
        remotePeerId,
        client,
        address,
      );

      delegate.onApproveSession(
        data,
        (accept, message) async {
          if (accept != null) {
            _updateState(WalletConnectState.connected);
          }
        },
      );
    }
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
*/
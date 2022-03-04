import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_dart/wallet_connect.dart';
import 'package:provenance_wallet/services/models/wallet_details.dart';
import 'package:provenance_wallet/services/wallet_service/wallet_connect_session.dart';
import 'package:provenance_wallet/services/wallet_service/wallet_connect_session_delegate.dart';
import 'package:provenance_wallet/services/wallet_service/wallet_connect_transaction_handler.dart';
import 'package:provenance_wallet/services/wallet_service/wallet_storage_service.dart';
import 'package:provenance_wallet/util/logs/logging.dart';
import 'package:rxdart/rxdart.dart';

typedef WalletConnectionProvider = WalletConnection Function(
  WalletConnectAddress address,
);

class WalletServiceEvents {
  final _subscriptions = CompositeSubscription();

  final _added = PublishSubject<WalletDetails>();
  final _removed = PublishSubject<List<WalletDetails>>();
  final _updated = PublishSubject<WalletDetails>();
  final _selected = PublishSubject<WalletDetails?>();

  Stream<WalletDetails> get added => _added;
  Stream<List<WalletDetails>> get removed => _removed;
  Stream<WalletDetails> get updated => _updated;
  Stream<WalletDetails?> get selected => _selected;

  void clear() {
    _subscriptions.clear();
  }

  void dispose() {
    _subscriptions.dispose();

    _added.close();
    _removed.close();
    _updated.close();
    _selected.close();
  }

  void listen(WalletServiceEvents other) {
    other.added.listen(_added.add).addTo(_subscriptions);
    other.removed.listen(_removed.add).addTo(_subscriptions);
    other.updated.listen(_updated.add).addTo(_subscriptions);
    other.selected.listen(_selected.add).addTo(_subscriptions);
  }
}

class WalletService implements Disposable {
  WalletService({
    required WalletStorageService storage,
    required WalletConnectionProvider connectionProvider,
  })  : _storage = storage,
        _connectionProvider = connectionProvider;

  final WalletStorageService _storage;
  final WalletConnectionProvider _connectionProvider;

  final events = WalletServiceEvents();

  @override
  FutureOr onDispose() {
    events.dispose();
  }

  Future<WalletDetails?> selectWallet({String? id}) async {
    final details = await _storage.selectWallet(id: id);

    events._selected.add(details);
  }

  Future<WalletDetails?> getSelectedWallet() => _storage.getSelectedWallet();

  Future<List<WalletDetails>> getWallets() => _storage.getWallets();

  Future<bool> getUseBiometry() async => _storage.getUseBiometry();

  Future setUseBiometry({
    required bool useBiometry,
  }) =>
      _storage.setUseBiometry(useBiometry);

  Future<WalletDetails?> renameWallet({
    required String id,
    required String name,
  }) async {
    final details = await _storage.renameWallet(
      id: id,
      name: name,
    );

    if (details != null) {
      events._updated.add(details);
    }

    return details;
  }

  Future<WalletDetails?> addWallet({
    required List<String> phrase,
    required String name,
    bool? useBiometry,
    Coin coin = Coin.testNet,
  }) async {
    final seed = Mnemonic.createSeed(phrase);
    final privateKey = PrivateKey.fromSeed(seed, coin);

    final details = await _storage.addWallet(
      name: name,
      privateKey: privateKey,
      useBiometry: useBiometry ?? false,
    );

    if (details != null) {
      events._added.add(details);
    }

    return details;
  }

  Future<WalletDetails?> removeWallet({required String id}) async {
    var details = await _storage.getWallet(id);
    if (details != null) {
      final success = await _storage.removeWallet(id);
      if (success) {
        events._removed.add([details]);
      } else {
        details = null;
      }
    }

    return details;
  }

  Future<List<WalletDetails>> resetWallets() async {
    final wallets = await _storage.getWallets();

    final success = await _storage.removeAllWallets();
    if (success) {
      events._removed.add(wallets);
    } else {
      wallets.clear();
    }

    return wallets;
  }

  Future<WalletConnectSession?> createSession(String addressData) async {
    WalletConnectSession? session;

    try {
      final currentWallet = await getSelectedWallet();
      final privateKey = await _storage.loadKey(currentWallet!.id);
      if (privateKey == null) {
        throw Exception("Failed to location the private key");
      }

      final address = WalletConnectAddress.create(addressData);
      if (address == null) {
        logStatic(
          WalletConnectSession,
          Level.error,
          'Invalid wallet connect address: $addressData',
        );

        return null;
      }

      final connection = _connectionProvider(address);

      final transactionHandler = WalletConnectTransactionHandler();

      final delegate = WalletConnectSessionDelegate(
        privateKey: privateKey,
        transactionHandler: transactionHandler,
      );

      session = WalletConnectSession(
        connection: connection,
        delegate: delegate,
      );
    } on Exception catch (e) {
      logError('Failed to connect session: $e');
    }

    return session;
  }

  Future<bool> isValidWalletConnectData(String qrData) =>
      Future.value(WalletConnectAddress.create(qrData) != null);
}

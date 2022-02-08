import 'dart:async';
import 'dart:developer';

import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/services/models/wallet_details.dart';
import 'package:provenance_wallet/services/requests/send_request.dart';
import 'package:provenance_wallet/services/requests/sign_request.dart';
import 'package:provenance_wallet/services/wallet_connect_service.dart';
import 'package:provenance_wallet/services/wallet_connect_status.dart';
import 'package:provenance_wallet/services/wallet_storage_service.dart';
import 'package:rxdart/rxdart.dart';

class WalletService {
  WalletService({
    required WalletStorageService storage,
    required WalletConnectService connect,
  })  : _storage = storage,
        _connect = connect {
    _connect.connected.listen((address) {
      _connectionStatus.add(WalletConnectStatus.connected);
      _walletAddress.add(address);
    });

    _connect.disconnected.listen((_) {
      _connectionStatus.add(WalletConnectStatus.disconnected);
      _walletAddress.add('');
    });
  }

  final WalletStorageService _storage;
  final WalletConnectService _connect;

  final _connectionStatus = BehaviorSubject.seeded(
    WalletConnectStatus.disconnected,
  );
  final _walletAddress = BehaviorSubject.seeded('');

  ValueStream<WalletConnectStatus> get status => _connectionStatus.stream;

  ValueStream<String> get walletAddress => _walletAddress.stream;

  Stream<SignRequest> get signRequest => _connect.signRequest;

  Stream<SendRequest> get sendRequest => _connect.sendRequest;

  Future<WalletDetails?> selectWallet({required String id}) =>
      _storage.selectWallet(id: id);

  Future<WalletDetails?> getSelectedWallet() =>_storage.getSelectedWallet();

    Future<List<WalletDetails>> getWallets() => _storage.getWallets();

    Future<bool> getUseBiometry() async =>  _storage.getUseBiometry();

    Future setUseBiometry({
      required bool useBiometry,
    }) =>
        _storage.setUseBiometry(useBiometry);

    Future renameWallet({
      required String id,
      required String name,
    }) =>
        _storage.renameWallet(
          id: id,
          name: name,
        );

    Future<bool> saveWallet({
      required List<String> phrase,
      required String name,
      bool? useBiometry,
      Coin coin = Coin.testNet,
    }) async {
      final seed = Mnemonic.createSeed(phrase);
      final privateKey = PrivateKey.fromSeed(seed, coin);

      return _storage.addWallet(
        name: name,
        privateKey: privateKey,
        useBiometry: useBiometry ?? false,
      );
    }

    Future removeWallet({required String id}) => _storage.removeWallet(id);

    Future resetWallets() async {
      await _connect.disconnectSession();
      await _storage.removeAllWallets();
    }

    Future disconnectSession() => _connect.disconnectSession();

    Future connectWallet(String qrData) => _connect.connectWallet(qrData);

    Future configureServer() => _connect.configureServer();

    Future signTransactionFinish({
      required String requestId,
      required bool allowed,
    }) =>
        _connect.signTransactionFinish(
          requestId: requestId,
          allowed: allowed,
        );

    Future sendMessageFinish({
      required requestId,
      required bool allowed,
    }) =>
        _connect.sendMessageFinish(
          requestId: requestId,
          allowed: allowed,
        );

    Future isValidWalletConnectData(String qrData) =>
        _connect.isValidWalletConnectData(qrData);
}

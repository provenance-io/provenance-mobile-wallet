import 'dart:async';
import 'dart:convert';
import 'package:provenance_dart/proto.dart' as proto;
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_dart/src/wallet/encoding/encoding.dart';
import 'package:provenance_dart/wallet_connect.dart';
import 'package:provenance_wallet/services/models/wallet_details.dart';
import 'package:provenance_wallet/services/wallet_connect_transaction_handler.dart';
import 'package:provenance_wallet/services/wallet_connect_session.dart';
import 'package:provenance_wallet/services/wallet_connect_session_delegate.dart';
import 'package:provenance_wallet/services/wallet_storage_service.dart';
import 'package:provenance_wallet/util/logs/logging.dart';
import '../extension/coin_helper.dart';

class WalletService {
  WalletService({
    required WalletStorageService storage,
  }) : _storage = storage;

  final WalletStorageService _storage;

  Future<WalletDetails?> selectWallet({required String id}) async {
    return await _storage.selectWallet(id: id);
  }

  Future<WalletDetails?> getSelectedWallet() => _storage.getSelectedWallet();

  Future<List<WalletDetails>> getWallets() => _storage.getWallets();

  Future<bool> getUseBiometry() async => _storage.getUseBiometry();

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

  Future<void> removeWallet({required String id}) => _storage.removeWallet(id);

  Future<void> resetWallets() async {
    await _storage.removeAllWallets();
  }

  Future<WalletConnectSession?> connectWallet(String addressData) async {
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

      final connection = WalletConnection(address);

      final transactionHandler = WalletConnectTransactionHandler();

      final delegate = WalletConnectSessionDelegate(
        privateKey: privateKey,
        transactionHandler: transactionHandler,
      );

      final newSession = WalletConnectSession(
        connection: connection,
        delegate: delegate,
      );

      final success = await newSession.connect();
      if (success) {
        session = newSession;
      }
    } on Exception catch (e) {
      logError('Failed to connect session: $e');
    }

    return session;
  }

  Future<bool> isValidWalletConnectData(String qrData) =>
      Future.value(WalletConnectAddress.create(qrData) != null);

  Future<int> estimate(proto.TxBody body, WalletDetails walletDetails) async {
    final pbClient = proto.PbClient(Uri.parse(walletDetails.coin.address), walletDetails.coin.chainId);
    final baseAccount = await pbClient.getBaseAccount(walletDetails.address);
    final baseReqSigner = proto.BaseReqSigner(
      _EstimateSigner(walletDetails), 
      baseAccount,
    );
    final baseReq = proto.BaseReq(body, [ baseReqSigner ], walletDetails.coin.chainId, );
    final gasEstimate = await pbClient.estimateTx(baseReq);

    return gasEstimate.fees;
  }
}


class _EstimateSigner extends proto.Signer {
  _EstimateSigner(this._details);

  final WalletDetails _details;

  @override
  String get address => _details.address;

  @override
  PublicKey get pubKey => PublicKey.fromUncompressedPublicKeyHex(_details.publicKey, _details.coin);
  @override
  List<int> sign(List<int> data) {
    return <int>[];
  }

}
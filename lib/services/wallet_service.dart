import 'dart:async';
import 'package:provenance_dart/proto.dart' as proto;
import 'package:provenance_dart/src/proto/gas.dart';
import 'package:provenance_dart/src/proto/proto_gen/cosmos/tx/v1beta1/tx.pb.dart';
import 'package:provenance_dart/src/proto/raw_tx_response.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_dart/wallet_connect.dart';
import 'package:provenance_wallet/services/models/wallet_details.dart';
import 'package:provenance_wallet/services/wallet_connect_service_imp.dart';
import 'package:provenance_wallet/services/wallet_connect_service.dart';
import 'package:provenance_wallet/services/wallet_storage_service.dart';

import '../extension/coin_helper.dart';

class _SignerImp implements proto.Signer {
  _SignerImp(this._privateKey);

  final PrivateKey _privateKey;

  @override
  String get address => pubKey.address;

  @override
  PublicKey get pubKey => _privateKey.defaultKey().publicKey;

  @override
  List<int> sign(List<int> data) {
    return _privateKey.signData(Hash.sha256(data))..removeLast();
  }
}

class WalletService
  implements TransactionHandler {
  WalletService({
    required WalletStorageService storage,
  })  : _storage = storage;

  final WalletStorageService _storage;

  WalletConnectService? _currentWalletConnect;

  WalletConnectService? get currentWalletConnect => _currentWalletConnect;

  Future<WalletDetails?> selectWallet({required String id}) =>
      _storage.selectWallet(id: id)
        .then((walletDetails) {
            _currentWalletConnect?.disconnectSession();

            return walletDetails;
        });

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
    await _currentWalletConnect?.disconnectSession();

    await _storage.removeAllWallets();
  }

  Future<void> connectWallet(String qrData) async {
    final address = WalletConnectAddress.create(qrData);

    if(address == null) {
      throw Exception("Invalid wallet connect address");
    }

    final currentWallet = await getSelectedWallet();
    final pKey = await _storage.loadKey(currentWallet!.id);
    if(pKey == null) {
      throw Exception("Failed to location the private key");
    }

    await _currentWalletConnect?.disconnectSession();

    final walletConnect = WalletConnection(address);
    _currentWalletConnect = WalletConnectServiceImp(pKey, walletConnect, this);
    _currentWalletConnect!.status.listen((event) {
      if(event == WalletConnectionServiceStatus.disconnected) {
        _currentWalletConnect = null;
      }
    });
  }

  Future isValidWalletConnectData(String qrData) =>
      Future.value(WalletConnectAddress.create(qrData) != null);

  /* TransactionHandler */
  @override
  Future<GasEstimate> estimateGas(TxBody txBody, PrivateKey privateKey) async {
    final publicKey = privateKey.defaultKey().publicKey;
    final coin = publicKey.coin;
    final pbClient = proto.PbClient(Uri.parse(coin.address), coin.chainId);

    final account = await pbClient.getBaseAccount(publicKey.address);
    final signer = _SignerImp(privateKey);
    final baseReqSigner = proto.BaseReqSigner(signer, account);

    final baseReq = proto.BaseReq(txBody,  [ baseReqSigner ], coin.chainId);

    return pbClient.estimateTx(baseReq);
  }

  @override
  Future<RawTxResponsePair> executeTransaction(TxBody txBody, PrivateKey privateKey) async {
    final publicKey = privateKey.defaultKey().publicKey;
    final coin = publicKey.coin;

    final pbClient = proto.PbClient(Uri.parse(coin.address), coin.chainId);
    final account = await pbClient.getBaseAccount(publicKey.address);
    final signer = _SignerImp(privateKey);

    final baseReqSigner = proto.BaseReqSigner(signer, account);

    return pbClient.estimateAndBroadcastTx(txBody, [ baseReqSigner ]);
  }
}

import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/services/models/wallet_details.dart';

abstract class WalletStorageService {
  WalletStorageService._();

  Future<List<WalletDetails>> getWallets();

  Future<WalletDetails?> getWallet({
    required String id,
  });

  Future<WalletDetails?> getSelectedWallet();

  Future<WalletDetails?> selectWallet({
    String? id,
  });

  Future<WalletDetails?> renameWallet({
    required String id,
    required String name,
  });

  Future<String> addWallet({
    required String name,
    required String address,
    required Coin coin,
  });

  Future removeWallet({required String id});

  Future removeAllWallets();
}

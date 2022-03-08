import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/services/models/wallet_details.dart';

abstract class WalletStorageService {
  WalletStorageService._();

  Future<List<WalletDetails>> getWallets();

  Future<WalletDetails?> getWallet(String id);

  Future<WalletDetails?> getSelectedWallet();

  Future<WalletDetails?> selectWallet({
    String? id,
  });

  Future<WalletDetails?> renameWallet({
    required String id,
    required String name,
  });

  Future<WalletDetails?> addWallet({
    required String name,
    required PrivateKey privateKey,
    required bool useBiometry,
  });

  Future<PrivateKey?> loadKey(String id);

  Future<bool> removeWallet(String id);

  Future<bool> removeAllWallets();

  Future<bool> getUseBiometry();

  Future<bool> setUseBiometry(bool useBiometry);
}

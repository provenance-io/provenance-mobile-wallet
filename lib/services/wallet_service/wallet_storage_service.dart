import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/services/models/wallet_details.dart';

class PublicKeyData {
  PublicKeyData({
    required this.address,
    required this.hex,
    required this.chainId,
  });

  final String address;
  final String hex;
  final String chainId;

  @override
  int get hashCode => hashValues(
        address,
        hex,
        chainId,
      );

  @override
  bool operator ==(Object other) {
    return other is PublicKeyData &&
        other.address == address &&
        other.hex == hex &&
        other.chainId == chainId;
  }
}

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
    required List<PrivateKey> privateKeys,
    required Coin selectedCoin,
  });

  Future<PrivateKey?> loadKey(String id, Coin coin);

  Future<bool> removeWallet(String id);

  Future<bool> removeAllWallets();

  Future<WalletDetails?> setWalletCoin({
    required String id,
    required Coin coin,
  });
}

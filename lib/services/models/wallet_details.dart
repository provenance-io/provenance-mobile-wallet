import 'package:provenance_dart/wallet.dart';

class WalletDetails {
  WalletDetails({
    required this.id,
    required this.address,
    required this.name,
    required this.publicKey,
    required this.coin,

  });

  final String id;
  final String address;
  final String name;
  final String publicKey;
  final Coin coin;
}

import 'package:provenance_blockchain_wallet/services/models/asset.dart';
import 'package:provenance_dart/wallet.dart';

class AssetDetails {
  AssetDetails(
    this.coin,
    this.asset,
    this.showAllTransactions,
  );

  final Coin coin;
  final Asset asset;
  final bool showAllTransactions;
}

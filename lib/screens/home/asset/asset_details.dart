import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/services/models/asset.dart';

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

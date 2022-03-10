import 'package:provenance_wallet/services/models/asset.dart';

class AssetDetails {
  AssetDetails(this.asset, this.showAllTransactions);

  final Asset asset;
  final bool showAllTransactions;
}

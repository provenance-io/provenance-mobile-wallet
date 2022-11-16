import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/util/localized_string.dart';

class Network {
  const Network({
    required this.chainId,
    required this.defaultCoin,
    required this.label,
  });

  static const mainNet = Network(
    chainId: 'pio-mainnet-1',
    defaultCoin: Coin.mainNet,
    label: LocalizedStringId(StringId.networkProvenanceMainnet),
  );
  static const testNet = Network(
    chainId: 'pio-testnet-1',
    defaultCoin: Coin.testNet,
    label: LocalizedStringId(StringId.networkProvenanceTestnet),
  );
  static List<Network> get values => const [
        mainNet,
        testNet,
      ];

  static Network forChainId(String chainId) =>
      values.firstWhere((e) => e.chainId == chainId);

  final String chainId;
  final Coin defaultCoin;

  final LocalizedString label;
}

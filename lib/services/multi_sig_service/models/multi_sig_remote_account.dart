import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/services/multi_sig_service/models/multi_sig_signer.dart';

class MultiSigRemoteAccount {
  MultiSigRemoteAccount({
    required this.remoteId,
    required this.name,
    required this.signers,
    required this.signersRequired,
    required this.coin,
  });

  final String remoteId;
  final String name;
  final List<MultiSigSigner> signers;
  final int signersRequired;
  final Coin coin;
}

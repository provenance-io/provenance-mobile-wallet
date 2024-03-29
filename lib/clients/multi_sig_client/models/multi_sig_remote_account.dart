import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/clients/multi_sig_client/models/multi_sig_signer.dart';

class MultiSigRemoteAccount {
  MultiSigRemoteAccount({
    required this.remoteId,
    required this.name,
    required this.signers,
    required this.signersRequired,
    required this.coin,
    this.address,
  });

  final String remoteId;
  final String name;
  final List<MultiSigSigner> signers;
  final int signersRequired;
  final Coin coin;
  final String? address;
}

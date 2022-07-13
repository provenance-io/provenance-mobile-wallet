import 'package:provenance_dart/wallet.dart';

class MultiSigSigner {
  MultiSigSigner({
    required this.inviteId,
    required this.signerOrder,
    this.publicKey,
  });

  final String inviteId;
  final int signerOrder;
  final PublicKey? publicKey;
}

import 'package:provenance_dart/wallet.dart';

class MultiSigSigner {
  MultiSigSigner({
    required this.inviteId,
    this.publicKey,
  });

  final String inviteId;
  final PublicKey? publicKey;
}

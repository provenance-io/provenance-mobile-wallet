import 'package:provenance_wallet/clients/multi_sig_client/models/multi_sig_signer.dart';

class MultiSigRegisterResult {
  MultiSigRegisterResult({
    this.signer,
    this.error,
  });

  final MultiSigSigner? signer;
  final String? error;
}

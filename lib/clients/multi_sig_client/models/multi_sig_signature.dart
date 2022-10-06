class MultiSigSignature {
  MultiSigSignature({
    required this.signerAddress,
    required this.signatureDecline,
    this.signatureHex,
  });

  final String signerAddress;
  final bool signatureDecline;
  final String? signatureHex;
}

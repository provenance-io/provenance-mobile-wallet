class SembastTxSigner {
  SembastTxSigner({
    required this.publicKey,
    required this.signature,
    required this.signerOrder,
  });

  final String publicKey;
  final String signature;
  final int signerOrder;

  Map<String, Object?> toRecord() => {
        'publicKey': publicKey,
        'signature': signature,
        'signerOrder': signerOrder,
      };

  factory SembastTxSigner.fromRecord(Map<String, Object?> rec) =>
      SembastTxSigner(
        publicKey: rec['publicKey'] as String,
        signature: rec['signature'] as String,
        signerOrder: rec['signerOrder'] as int,
      );
}

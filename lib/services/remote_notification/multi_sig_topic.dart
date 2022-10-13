enum MultiSigTopic {
  accountComplete(id: 'MULTISIG_WALLET_COMPLETE'),
  txSignatureRequired(id: 'MULTISIG_TX_SIGNATURE_REQUIRED'),
  txReady(id: 'MULTISIG_TX_READY'),
  txDeclined(id: 'MULTISIG_TX_DECLINED'),
  txResult(id: 'MULTISIG_TX_RESULT');

  const MultiSigTopic({
    required this.id,
  });

  final String id;

  factory MultiSigTopic.fromJson(String value) =>
      MultiSigTopic.values.firstWhere((e) => e.id == value);

  String toJson() => id;
}

enum MultiSigTopic {
  accountComplete(id: 'MULTISIG_WALLET_COMPLETE'),
  txSignatureRequired(id: 'MULTISIG_TX_SIGNATURE_REQUIRED'),
  txReady(id: 'MULTISIG_TX_READY'),
  txResult(id: 'MULTISIG_TX_RESULT');

  const MultiSigTopic({
    required this.id,
  });

  final String id;
}

class WalletConnectTxResponse {
  WalletConnectTxResponse({
    required this.code,
    this.message,
  });

  final int code;
  final String? message;
}

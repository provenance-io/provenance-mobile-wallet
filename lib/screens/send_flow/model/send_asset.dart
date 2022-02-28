class SendAsset {
  SendAsset(
    this.denom,
    this.amount,
    this.fiatValue,
    this.imageUrl,
  );

  final String denom;
  final String amount;
  final String fiatValue;
  final String imageUrl;
}

import 'package:provenance_dart/wallet_connect.dart';

extension WalletConnectAddressHelper on WalletConnectAddress {
  String get fullUriString =>
      "wc:$topic@$version?bridge=${Uri.encodeComponent(bridge.toString())}&key=$key";

  Uri get fullUri => Uri.parse(fullUriString);
}

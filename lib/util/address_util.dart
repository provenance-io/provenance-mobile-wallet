import 'package:provenance_dart/wallet.dart';

String abbreviateAddress(String address) {
  const left = 3;
  const right = 8;
  const dots = '...';

  return address.length > left + dots.length + right
      ? '${address.substring(0, left)}$dots${address.substring(address.length - right)}'
      : address;
}

String? convertAddress(Object? data) {
  return data is String ? abbreviateAddress(data) : null;
}

String abbreviateAddressAlt(String address) {
  const left = 3;
  const right = 4;
  const dots = '...';

  return address.length > left + dots.length + right
      ? '${address.substring(0, left)}$dots[${address.substring(address.length - right)}]'
      : address;
}

Coin getCoinFromAddress(String address) {
  final prefix = address.substring(0, 2);
  switch (prefix) {
    case 'pb':
      return Coin.mainNet;
    case 'tp':
      return Coin.testNet;
    default:
      throw 'Unknown coin prefix: $prefix';
  }
}

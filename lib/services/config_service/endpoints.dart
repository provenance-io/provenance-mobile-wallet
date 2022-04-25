import 'package:json_annotation/json_annotation.dart';
import 'package:provenance_blockchain_wallet/services/config_service/flavor.dart';
import 'package:provenance_dart/wallet.dart';

part 'endpoints.g.dart';

///
/// See Endpoints on Notion
/// https://www.notion.so/figuretech/Provenance-Dev-Links-f1e3a2b081b64017b957ec3b81a3f790
///
/// A Firebase remote config is used if it is present and has a higher version
/// than this default.
///
const _endpoints = Endpoints(
  version: 1,
  figureTech: Endpoint(
    mainUrl: 'https://www.figure.tech/',
    testUrl: 'https://test.figure.tech/',
  ),
  chain: Endpoint(
    mainUrl: 'grpc://34.148.50.57:9090',
    testUrl: 'grpc://34.148.39.82:9090',
  ),
);

@JsonSerializable()
class Endpoints {
  const Endpoints({
    required this.version,
    required this.figureTech,
    required this.chain,
  });

  final int version;
  final Endpoint figureTech;
  final Endpoint chain;

  static Endpoints forFlavor(Flavor flavor) {
    switch (flavor) {
      case Flavor.prod:
        return _endpoints;
      case Flavor.dev:
        return _endpoints;
    }
  }

  @override
  String toString() {
    return '$Endpoints(version: "$version", figureTech: "$figureTech", chain: "$chain")';
  }

  // ignore: member-ordering
  factory Endpoints.fromJson(Map<String, dynamic> json) =>
      _$EndpointsFromJson(json);
  Map<String, dynamic> toJson() => _$EndpointsToJson(this);
}

@JsonSerializable()
class Endpoint {
  const Endpoint({
    required this.mainUrl,
    required this.testUrl,
  });

  final String mainUrl;
  final String testUrl;

  String forCoin(Coin coin) {
    switch (coin) {
      case Coin.mainNet:
        return mainUrl;
      case Coin.testNet:
        return testUrl;
    }
  }

  @override
  String toString() {
    return '$Endpoint(mainUrl: "$mainUrl", testUrl: "$testUrl")';
  }

  // ignore: member-ordering
  factory Endpoint.fromJson(Map<String, dynamic> json) =>
      _$EndpointFromJson(json);
  Map<String, dynamic> toJson() => _$EndpointToJson(this);
}

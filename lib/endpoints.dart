import 'package:provenance_dart/wallet.dart';

///
/// See Endpoints on Notion
/// https://www.notion.so/figuretech/Provenance-Dev-Links-f1e3a2b081b64017b957ec3b81a3f790
///
class Endpoints {
  static const figureTech = Endpoint(
    mainUrl: 'https://www.figure.tech/',
    testUrl: 'https://test.figure.tech/',
  );

  static const chain = Endpoint(
    mainUrl: 'grpc://34.148.50.57:9090',
    testUrl: 'grpc://34.148.39.82:9090',
  );
}

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
}

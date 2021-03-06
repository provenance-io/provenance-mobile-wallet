import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prov_wallet_flutter/prov_wallet_flutter.dart';

main() {
  MethodChannel? _channel;
  Map<String, dynamic>? _results;
  Map<String, dynamic>? _methodArgs;

  CipherService? _cipherService;

  Future<dynamic> _channelHandler(MethodCall methodCall) {
    final method = methodCall.method;
    final result = _results![method];
    _methodArgs![method] = methodCall.arguments;

    return Future.value(result);
  }

  setUp(() {
    _results = <String, dynamic>{};
    _methodArgs = <String, dynamic>{};

    _channel = const MethodChannel('prov_wallet_flutter');

    _cipherService = PlatformCipherService();
  });

  group("encryptKey", () {
    const id = "TestId";
    const bip32Serialized =
        "tprv8kxV73NnPZyfSNfQThb5zjzysmbmGABtrZsGNcuhKnqPsmJFuyBvwJzSA24V59AAYWJfBVGxu4fGSKiLh3czp6kE1NNpP2SqUvHeStr8DC1";

    testWidgets('success', (tester) async {
      tester.binding.defaultBinaryMessenger
          .setMockMethodCallHandler(_channel!, _channelHandler);

      _results!["encryptKey"] = true;
      final result = await _cipherService!.encryptKey(
        id: id,
        privateKey: bip32Serialized,
      );

      expect(result, true);
      expect(_methodArgs!["encryptKey"], <String, dynamic>{
        "id": id,
        "private_key": bip32Serialized,
      });
    });
  });

  group("decryptKey", () {
    const bip32Serialized =
        "tprv8kxV73NnPZyfSNfQThb5zjzysmbmGABtrZsGNcuhKnqPsmJFuyBvwJzSA24V59AAYWJfBVGxu4fGSKiLh3czp6kE1NNpP2SqUvHeStr8DC1";
    const id = "TestId";

    testWidgets('success', (tester) async {
      tester.binding.defaultBinaryMessenger
          .setMockMethodCallHandler(_channel!, _channelHandler);

      _results!["decryptKey"] = bip32Serialized;

      final result = await _cipherService!.decryptKey(id: id);
      expect(result, bip32Serialized);
      expect(_methodArgs!["decryptKey"], <String, dynamic>{
        "id": id,
      });
    });
  });

  group("getUseBiometry", () {
    testWidgets('success', (tester) async {
      tester.binding.defaultBinaryMessenger
          .setMockMethodCallHandler(_channel!, _channelHandler);

      _results!["getUseBiometry"] = true;

      final result = await _cipherService!.getUseBiometry();
      expect(result, true);
    });
  });

  group("setUseBiometry", () {
    testWidgets('success', (tester) async {
      tester.binding.defaultBinaryMessenger
          .setMockMethodCallHandler(_channel!, _channelHandler);

      _results!["setUseBiometry"] = false;

      final result = await _cipherService!.setUseBiometry(useBiometry: true);
      expect(result, false);
      expect(_methodArgs!["setUseBiometry"], {
        "use_biometry": true,
      });
    });
  });
}

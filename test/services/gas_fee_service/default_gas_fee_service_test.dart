import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/services/gas_fee/default_gas_fee_client.dart';
import 'package:provenance_wallet/services/http_client.dart';
import 'package:provenance_wallet/services/models/base_response.dart';
import 'package:provenance_wallet/services/models/gas_price.dart';
import 'package:provenance_wallet/services/notification/notification_group.dart';
import 'package:provenance_wallet/services/notification/notification_service.dart';
import 'package:provenance_wallet/util/get.dart';

import './default_gas_fee_service_test.mocks.dart';

@GenerateMocks([TestHttpClient, NotificationService])
main() {
  MockTestHttpClient? mockHttpClient;
  MockNotificationService? mockNotificationService;
  DefaultGasFeeClient? assetService;

  setUp(() async {
    mockNotificationService = MockNotificationService();
    get.registerSingleton<NotificationService>(mockNotificationService!);

    mockHttpClient = MockTestHttpClient();
    get.registerSingleton<Future<TestHttpClient>>(
      Future.value(mockHttpClient!),
    );

    assetService = DefaultGasFeeClient();
  });

  void _setupResults<X>(X? futureResult) {
    when(mockHttpClient!.get<X>(
      any,
      listConverter: anyNamed("listConverter"),
      converter: anyNamed("converter"),
      additionalHeaders: anyNamed("additionalHeaders"),
      queryStringParameters: anyNamed("queryStringParameters"),
      documentDownload: anyNamed("documentDownload"),
      ignore403: anyNamed("ignore403"),
      responseType: anyNamed("responseType"),
    )).thenAnswer((realInvocation) async {
      final listConverter = realInvocation.namedArguments["listConverter"];
      final converter = realInvocation.namedArguments["converter"];

      return BaseResponse<X>(
        Response(data: futureResult, requestOptions: RequestOptions(path: "")),
        converter,
        listConverter,
      ) as dynamic;
    });
  }

  tearDown(() async {
    get.reset(dispose: true);
  });

  group("getGasFee", () {
    test('notification success', () async {
      _setupResults<GasPrice>(null);

      await assetService!.getPrice(Coin.testNet);

      verify(mockNotificationService!
          .dismissGrouped(NotificationGroup.serviceError, argThat(isNotNull)));
    });

    // test('notification Error', () async {
    //   when(mockHttpClient!.get<List<Asset>>(
    //     any,
    //     listConverter: anyNamed("listConverter"),
    //     converter: anyNamed("converter"),
    //     additionalHeaders: anyNamed("additionalHeaders"),
    //     queryStringParameters: anyNamed("queryStringParameters"),
    //     documentDownload: anyNamed("documentDownload"),
    //     ignore403: anyNamed("ignore403"),
    //     responseType: anyNamed("responseType"),
    //   )).thenAnswer((realInvocation) async {
    //     final converter = realInvocation.namedArguments["converter"];
    //     final json = <Map<String, dynamic>>{};

    //     return BaseResponse(
    //       Response(data: json, requestOptions: RequestOptions(path: "")),
    //       converter,
    //       (_) => throw Exception("Exception"),
    //     );
    //   });

    //   await assetService!.getAssets("ABCDE");

    //   verify(mockNotificationService!
    //       .dismissGrouped(NotificationGroup.serviceError, argThat(isNotNull)));
    // });

    test('url', () async {
      _setupResults<GasPrice>(null);

      await assetService!.getPrice(Coin.testNet);

      var captures = verify(mockHttpClient!.get(
        captureAny,
        listConverter: null,
        converter: anyNamed("converter"),
        additionalHeaders: null,
        queryStringParameters: null,
        documentDownload: false,
        ignore403: false,
      )).captured;

      expect(
        captures.first as String,
        '/service-mobile-wallet/external/api/v1/pricing/gas-price',
      );
    });

    test('result', () async {
      final fee = GasPrice(
        denom: "Usd",
        amountPerUnit: 2,
      );

      _setupResults<GasPrice>(fee);

      final result = await assetService!.getPrice(Coin.testNet);

      expect(
        result,
        fee,
      );
    });

    test('Converter', () async {
      _setupResults<GasPrice>(null);

      await assetService!.getPrice(Coin.testNet);

      var captures = verify(mockHttpClient!.get(
        any,
        listConverter: null,
        converter: captureAnyNamed("converter"),
        additionalHeaders: null,
        queryStringParameters: null,
        documentDownload: false,
        ignore403: false,
      )).captured;

      final listConverter =
          captures.first as GasPrice? Function(Map<String, dynamic> json);

      final json = <String, dynamic>{
        "gasPriceDenom": "nhash",
        "gasPrice": 1001,
      };

      final converted = listConverter(json);
      expect(converted!.amountPerUnit, 1001);
      expect(converted.denom, "nhash");
    });
  });
}

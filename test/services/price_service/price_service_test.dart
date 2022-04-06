import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/services/http_client.dart';
import 'package:provenance_wallet/services/models/base_response.dart';
import 'package:provenance_wallet/services/models/price.dart';
import 'package:provenance_wallet/services/notification/notification_group.dart';
import 'package:provenance_wallet/services/notification/notification_service.dart';
import 'package:provenance_wallet/services/price_service/dtos/price_dto.dart';
import 'package:provenance_wallet/services/price_service/price_service.dart';
import 'package:provenance_wallet/util/get.dart';

import 'price_service_test.mocks.dart';

@GenerateMocks([TestHttpClient, NotificationService])
main() {
  MockTestHttpClient? mockHttpClient;
  MockNotificationService? mockNotificationService;
  PriceService? priceService;

  setUp(() async {
    mockNotificationService = MockNotificationService();
    get.registerSingleton<NotificationService>(mockNotificationService!);

    mockHttpClient = MockTestHttpClient();
    get.registerSingleton<TestHttpClient>(mockHttpClient!);

    priceService = PriceService();
  });

  tearDown(() async {
    get.reset(dispose: true);
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

  group("getAssetPrices", () {
    test('no notification', () async {
      _setupResults<List<Price>>(null);

      await priceService!.getAssetPrices(Coin.testNet, ['A']);

      verifyNever(mockNotificationService!
          .dismissGrouped(NotificationGroup.serviceError, argThat(isNotNull)));
    });

    test('url', () async {
      _setupResults<List<Price>>(null);

      await priceService!.getAssetPrices(Coin.testNet, ["A", "b"]);

      var captures = verify(mockHttpClient!.get(
        captureAny,
        listConverter: anyNamed("listConverter"),
        converter: null,
        additionalHeaders: null,
        queryStringParameters: null,
        documentDownload: false,
        ignore403: false,
      )).captured;

      expect(
        captures.first as String,
        '/service-pricing-engine//service-pricing-engine/api/v1/pricing/marker/denom/list?denom[]=A,b',
      );
    });

    test('result', () async {
      final prices = [
        Price(
          dto: PriceDto(
            usdPrice: 123.0,
            markerDenom: "ABC",
          ),
        ),
        Price(
          dto: PriceDto(
            usdPrice: 2.0,
            markerDenom: "Z",
          ),
        ),
      ];

      _setupResults<List<Price>>(prices);

      final result = await priceService!.getAssetPrices(Coin.testNet, ['a']);

      expect(
        result,
        prices,
      );
    });

    test('Converter', () async {
      _setupResults<List<Price>>(null);

      await priceService!.getAssetPrices(Coin.testNet, ['a']);

      var captures = verify(mockHttpClient!.get(
        any,
        listConverter: captureAnyNamed("listConverter"),
        converter: null,
        additionalHeaders: null,
        queryStringParameters: null,
        documentDownload: false,
        ignore403: false,
      )).captured;

      final listConverter =
          captures.first as List<Price>? Function(List<dynamic> json);

      final json = [
        {
          "usdPrice": 123.0,
          "markerDenom": "a",
        },
        {
          "usdPrice": 1.0,
          "markerDenom": "b",
        },
      ];

      final converted = listConverter(json);
      expect(converted!.length, 2);
      expect(converted[0].denomination, "a");
      expect(converted[0].usdPrice, 123.0);
      expect(converted[1].denomination, "b");
      expect(converted[1].usdPrice, 1.0);
    });
  });
}

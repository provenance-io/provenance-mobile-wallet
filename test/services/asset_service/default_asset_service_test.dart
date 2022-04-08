import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/extension/date_time.dart';
import 'package:provenance_wallet/services/asset_service/asset_service.dart';
import 'package:provenance_wallet/services/asset_service/default_asset_service.dart';
import 'package:provenance_wallet/services/asset_service/dtos/asset_dto.dart';
import 'package:provenance_wallet/services/asset_service/dtos/asset_graph_item_dto.dart';
import 'package:provenance_wallet/services/http_client.dart';
import 'package:provenance_wallet/services/models/asset.dart';
import 'package:provenance_wallet/services/models/asset_graph_item.dart';
import 'package:provenance_wallet/services/models/base_response.dart';
import 'package:provenance_wallet/services/notification/notification_group.dart';
import 'package:provenance_wallet/services/notification/notification_service.dart';
import 'package:provenance_wallet/util/get.dart';

import './default_asset_service_test.mocks.dart';

@GenerateMocks([TestHttpClient, NotificationService])
main() {
  MockTestHttpClient? mockHttpClient;
  MockNotificationService? mockNotificationService;
  DefaultAssetService? assetService;

  setUp(() async {
    mockNotificationService = MockNotificationService();
    get.registerSingleton<NotificationService>(mockNotificationService!);

    mockHttpClient = MockTestHttpClient();
    get.registerSingleton<TestHttpClient>(mockHttpClient!);

    assetService = DefaultAssetService();
  });

  void _setupResults<X>(List<X>? futureResult) {
    when(mockHttpClient!.get<List<X>>(
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

      return BaseResponse<List<X>>(
        Response(data: futureResult, requestOptions: RequestOptions(path: "")),
        converter,
        listConverter,
      ) as dynamic;
    });
  }

  tearDown(() async {
    get.reset(dispose: true);
  });

  group("getAssets", () {
    test('notification success', () async {
      _setupResults<Asset>(null);

      await assetService!.getAssets(Coin.testNet, "ABCDE");

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
      _setupResults<Asset>(null);

      await assetService!.getAssets(Coin.testNet, "ABCDE");

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
        '/service-mobile-wallet/external/api/v1/address/ABCDE/assets',
      );
    });

    test('result', () async {
      final assets = [
        Asset(
          dto: AssetDto(
            amount: "1",
            denom: "nhash",
            usdPrice: 123,
            display: "a",
            description: "b",
            displayAmount: "1234",
            exponent: 9,
          ),
        ),
        Asset(
          dto: AssetDto(
            amount: "2",
            denom: "Usd",
            usdPrice: 100,
            display: "a",
            description: "b",
            displayAmount: "1234",
            exponent: 2,
          ),
        ),
      ];

      _setupResults<Asset>(assets);

      final results = await assetService!.getAssets(Coin.testNet, "ABCDE");

      expect(
        results,
        assets,
      );
    });

    test('list Converter', () async {
      _setupResults<Asset>(null);

      await assetService!.getAssets(Coin.testNet, "ABCDE");

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
          captures.first as List<Asset> Function(List<dynamic> json);

      final json = [
        <String, dynamic>{
          "denom": "nhash",
          "amount": "1001",
          "display": "100.1",
          "description": "nhash token",
          "exponent": 4,
          "displayAmount": "111",
          "usdPrice": 1234,
        },
        <String, dynamic>{
          "denom": "usd",
          "amount": "10",
          "display": "11",
          "description": "usd token token",
          "exponent": 2,
          "displayAmount": "123",
          "usdPrice": 11.1,
        },
      ];

      final converted = listConverter(json);
      expect(converted.length, 2);
      expect(converted[0].amount, "1001");
      expect(converted[0].denom, "nhash");
      expect(converted[0].description, "nhash token");
      expect(converted[0].display, "100.1");
      expect(converted[0].displayAmount, "111");
      expect(converted[0].exponent, 4);
      expect(converted[0].usdPrice, 1234);

      expect(converted[1].amount, "10");
      expect(converted[1].denom, "usd");
      expect(converted[1].description, "usd token token");
      expect(converted[1].display, "11");
      expect(converted[1].displayAmount, "123");
      expect(converted[1].exponent, 2);
      expect(converted[1].usdPrice, 11.1);
    });
  });

  group("getAssetGraphingData", () {
    test('notification success', () async {
      _setupResults<AssetGraphItem>(null);

      await assetService!.getAssetGraphingData(
        Coin.testNet,
        "AssetTypeA",
        GraphingDataValue.all,
      );

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
      _setupResults<AssetGraphItem>(null);

      final dateFormat = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS");
      final now = DateTime.now();

      await assetService!.getAssetGraphingData(
        Coin.testNet,
        "AssetTypeA",
        GraphingDataValue.all,
      );

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
        '/service-mobile-wallet/external/api/v1/pricing/marker/AssetTypeA?period=ALL&startDate=${dateFormat.format(now.startOfDay.toUtc())}-00:00&endDate=${dateFormat.format(now.endOfDay.toUtc())}-00:00',
      );
    });

    test('result', () async {
      final assets = [
        AssetGraphItem(
          dto: AssetGraphItemDto(
            price: 123,
            timestamp: DateTime.fromMillisecondsSinceEpoch(100),
          ),
        ),
        AssetGraphItem(
          dto: AssetGraphItemDto(
            price: 456,
            timestamp: DateTime.fromMillisecondsSinceEpoch(400),
          ),
        ),
      ];

      _setupResults<AssetGraphItem>(assets);

      final results = await assetService!.getAssetGraphingData(
        Coin.testNet,
        "ABCDE",
        GraphingDataValue.all,
      );

      expect(
        results,
        assets,
      );
    });

    test('list Converter', () async {
      _setupResults<AssetGraphItem>(null);

      await assetService!.getAssetGraphingData(
        Coin.testNet,
        "ABCDE",
        GraphingDataValue.all,
      );

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
          captures.first as List<AssetGraphItem> Function(List<dynamic> json);

      final json = [
        <String, dynamic>{
          "timestamp": "2022-01-10T08:09:10",
          "price": 1001,
        },
        <String, dynamic>{
          "timestamp": "2022-04-10T08:09:10",
          "price": 2001,
        },
      ];

      final converted = listConverter(json);
      expect(converted.length, 2);
      expect(converted[0].price, 1001);
      expect(converted[0].timestamp, DateTime.parse("2022-01-10T08:09:10"));

      expect(converted[1].price, 2001);
      expect(converted[1].timestamp, DateTime.parse("2022-04-10T08:09:10"));
    });
  });
}

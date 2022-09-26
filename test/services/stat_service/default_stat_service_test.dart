import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/services/http_client.dart';
import 'package:provenance_wallet/services/models/base_response.dart';
import 'package:provenance_wallet/services/models/onboarding_stat.dart';
import 'package:provenance_wallet/services/notification/notification_group.dart';
import 'package:provenance_wallet/services/notification/notification_service.dart';
import 'package:provenance_wallet/services/stat_service/default_stat_client.dart';
import 'package:provenance_wallet/services/stat_service/dtos/stat_dto.dart';
import 'package:provenance_wallet/util/get.dart';

import 'default_stat_service_test.mocks.dart';

@GenerateMocks([TestHttpClient, NotificationService])
main() {
  MockTestHttpClient? mockHttpClient;
  MockNotificationService? mockNotificationService;
  DefaultStatClient? statService;

  setUp(() async {
    mockNotificationService = MockNotificationService();
    get.registerSingleton<NotificationService>(mockNotificationService!);

    mockHttpClient = MockTestHttpClient();
    get.registerSingleton<Future<TestHttpClient>>(
      Future.value(mockHttpClient!),
    );

    statService = DefaultStatClient();
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

  group("getStats", () {
    test('no notification', () async {
      _setupResults<OnboardingStat>(null);

      await statService!.getStats(Coin.testNet);

      verifyNever(mockNotificationService!
          .dismissGrouped(NotificationGroup.serviceError, argThat(isNotNull)));
    });

    test('url', () async {
      _setupResults<OnboardingStat>(null);

      await statService!.getStats(Coin.testNet);

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
        '/service-mobile-wallet/external/api/v1/statistics',
      );
    });

    test('result', () async {
      final prices = OnboardingStat(
        dto: StatDto(
          marketCap: 1.3,
          validators: 4,
          transactions: 100,
          averageBlockTime: 345.666,
        ),
      );

      _setupResults<OnboardingStat>(prices);

      final result = await statService!.getStats(Coin.testNet);

      expect(
        result,
        prices,
      );
    });

    test('Converter', () async {
      _setupResults<OnboardingStat>(null);

      await statService!.getStats(Coin.testNet);

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
          captures.first as OnboardingStat? Function(Map<String, dynamic> json);

      final json = {
        "marketCap": 1300000000,
        "validators": 4,
        "transactions": 100,
        "averageBlockTime": 345.666,
      };

      final converted = listConverter(json)!;
      expect(converted.marketCap, "\$1.3B");
      expect(converted.validators, 4);
      expect(converted.transactions, "0.1k");
      expect(converted.blockTime, "345.666sec");
    });
  });
}

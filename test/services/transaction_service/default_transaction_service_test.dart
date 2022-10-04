import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/services/http_client.dart';
import 'package:provenance_wallet/services/models/base_response.dart';
import 'package:provenance_wallet/services/models/transaction.dart';
import 'package:provenance_wallet/services/notification/notification_group.dart';
import 'package:provenance_wallet/services/notification/notification_service.dart';
import 'package:provenance_wallet/services/transaction_client/default_transaction_client.dart';
import 'package:provenance_wallet/services/transaction_client/dtos/transaction_dto.dart';
import 'package:provenance_wallet/util/get.dart';

import 'default_transaction_service_test.mocks.dart';

@GenerateMocks([TestHttpClient, NotificationService])
main() {
  MockTestHttpClient? mockHttpClient;
  MockNotificationService? mockNotificationService;
  DefaultTransactionClient? statService;

  setUp(() async {
    mockNotificationService = MockNotificationService();
    get.registerSingleton<NotificationService>(mockNotificationService!);

    mockHttpClient = MockTestHttpClient();
    get.registerSingleton<Future<TestHttpClient>>(
      Future.value(mockHttpClient!),
    );

    statService = DefaultTransactionClient();
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
      _setupResults<List<Transaction>>(null);

      await statService!.getTransactions(
        Coin.testNet,
        "AB",
        1,
      );

      verify(mockNotificationService!
          .dismissGrouped(NotificationGroup.serviceError, argThat(isNotNull)));
    });

    test('url', () async {
      _setupResults<List<Transaction>>(null);

      await statService!.getTransactions(
        Coin.testNet,
        "AB",
        1,
      );

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
        '/service-mobile-wallet/external/api/v1/address/AB/transactions/all?count=50&page=1',
      );
    });

    test('result', () async {
      final trans = [
        Transaction(
          dto: TransactionDto(
            block: 2,
            hash:
                "F78DE603565AB2CEDC5C990F0F7F56ADF670F7A86BBAC2C283CB5445F68CEFD7",
            status: "SUCCESS",
            feeAmount: "200",
            signer: "BBB",
            time: DateTime.now(),
            type: "A",
          ),
        ),
      ];

      _setupResults<List<Transaction>>(trans);

      final result = await statService!.getTransactions(
        Coin.testNet,
        "AB",
        1,
      );

      expect(
        result,
        trans,
      );
    });

    test('Converter', () async {
      _setupResults<List<Transaction>>(null);

      await statService!.getTransactions(
        Coin.testNet,
        "AB",
        1,
      );

      var captures = verify(mockHttpClient!.get(
        any,
        listConverter: null,
        converter: captureAnyNamed("converter"),
        additionalHeaders: null,
        queryStringParameters: null,
        documentDownload: false,
        ignore403: false,
      )).captured;

      final listConverter = captures.first as List<Transaction>? Function(
        Map<String, dynamic> json,
      );

      final json = {
        "pages": 2,
        "totalCount": 5,
        "transactions": [
          {
            "hash":
                "F78DE603565AB2CEDC5C990F0F7F56ADF670F7A86BBAC2C283CB5445F68CEFD7",
            "block": 6159353,
            "status": "SUCCESS",
            "time": "2022-02-07T20:26:48Z",
            "pricePerUnit": 9.4E-11,
            "totalPrice": 94.000000000000,
            "signer": "tp1mpapyn7sgdrrmpx8ed7haprt8m0039gg0nyn8f",
            "feeAmount": "958916040",
            "type": "A",
          },
        ],
      };

      final converted = listConverter(json)!;
      expect(converted.length, 1);
      expect(
        converted[0].hash,
        "F78DE603565AB2CEDC5C990F0F7F56ADF670F7A86BBAC2C283CB5445F68CEFD7",
      );
      expect(
        converted[0].block,
        6159353,
      );
      expect(converted[0].status, "SUCCESS");
    });
  });
}

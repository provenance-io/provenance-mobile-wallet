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
import 'package:provenance_wallet/services/transaction_service/default_transaction_service.dart';
import 'package:provenance_wallet/services/transaction_service/dtos/transaction_dto.dart';
import 'package:provenance_wallet/util/get.dart';

import 'default_transaction_service_test.mocks.dart';

@GenerateMocks([TestHttpClient, NotificationService])
main() {
  MockTestHttpClient? mockHttpClient;
  MockNotificationService? mockNotificationService;
  DefaultTransactionService? statService;

  setUp(() async {
    mockNotificationService = MockNotificationService();
    get.registerSingleton<NotificationService>(mockNotificationService!);

    mockHttpClient = MockTestHttpClient();
    get.registerSingleton<TestHttpClient>(mockHttpClient!);

    statService = DefaultTransactionService();
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

      await statService!.getTransactions(Coin.testNet, "AB");

      verify(mockNotificationService!
          .dismissGrouped(NotificationGroup.serviceError, argThat(isNotNull)));
    });

    test('url', () async {
      _setupResults<List<Transaction>>(null);

      await statService!.getTransactions(Coin.testNet, "AB");

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
        '/service-mobile-wallet/external/api/v1/address/AB/transactions',
      );
    });

    test('result', () async {
      final trans = [
        Transaction(
          dto: TransactionDto(
            amount: 100,
            block: 2,
            denom: "nhash",
            hash:
                "F78DE603565AB2CEDC5C990F0F7F56ADF670F7A86BBAC2C283CB5445F68CEFD7",
            recipientAddress: "tp1g5ugfegkl5gmn049n5a9hgjn3ged0ekp8f2fwx",
            senderAddress: "tp1mpapyn7sgdrrmpx8ed7haprt8m0039gg0nyn8f",
            status: "SUCCESS",
            timestamp: DateTime.parse("2022-02-07T20:26:48Z"),
            txFee: 958916040,
            pricePerUnit: 9.4E-11,
            totalPrice: 94.00,
            exponent: 9,
          ),
        ),
      ];

      _setupResults<List<Transaction>>(trans);

      final result = await statService!.getTransactions(Coin.testNet, "AB");

      expect(
        result,
        trans,
      );
    });

    test('Converter', () async {
      _setupResults<List<Transaction>>(null);

      await statService!.getTransactions(Coin.testNet, "AB");

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
          captures.first as List<Transaction>? Function(List<dynamic> json);

      final json = [
        {
          "hash":
              "F78DE603565AB2CEDC5C990F0F7F56ADF670F7A86BBAC2C283CB5445F68CEFD7",
          "block": 6159353,
          "txFee": 958916040,
          "recipientAddress": "tp1g5ugfegkl5gmn049n5a9hgjn3ged0ekp8f2fwx",
          "senderAddress": "tp1mpapyn7sgdrrmpx8ed7haprt8m0039gg0nyn8f",
          "amount": 1000000000000,
          "denom": "nhash",
          "status": "SUCCESS",
          "timestamp": "2022-02-07T20:26:48Z",
          "exponent": 9,
          "pricePerUnit": 9.4E-11,
          "totalPrice": 94.000000000000,
        },
      ];

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
      expect(
        converted[0].txFee,
        958916040,
      );
      expect(
        converted[0].recipientAddress,
        "tp1g5ugfegkl5gmn049n5a9hgjn3ged0ekp8f2fwx",
      );
      expect(
        converted[0].senderAddress,
        "tp1mpapyn7sgdrrmpx8ed7haprt8m0039gg0nyn8f",
      );
      expect(converted[0].amount, 1000000000000);
      expect(converted[0].denom, "nhash");
      expect(converted[0].status, "SUCCESS");
      expect(converted[0].timestamp, DateTime.parse("2022-02-07T20:26:48Z"));
      expect(converted[0].exponent, 9);
      expect(converted[0].pricePerUnit, 9.4E-11);
      expect(converted[0].totalPrice, 94.000000000000);
    });
  });
}

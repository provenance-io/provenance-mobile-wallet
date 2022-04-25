import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provenance_blockchain_wallet/screens/send_flow/send_flow.dart';
import 'package:provenance_blockchain_wallet/services/asset_service/asset_service.dart';
import 'package:provenance_blockchain_wallet/services/models/asset.dart';
import 'package:provenance_blockchain_wallet/services/models/price.dart';
import 'package:provenance_blockchain_wallet/services/models/transaction.dart';
import 'package:provenance_blockchain_wallet/services/price_service/price_service.dart';
import 'package:provenance_blockchain_wallet/services/transaction_service/transaction_service.dart';
import 'package:provenance_blockchain_wallet/services/wallet_service/model/wallet_gas_estimate.dart';
import 'package:provenance_blockchain_wallet/services/wallet_service/transaction_handler.dart';
import 'package:provenance_blockchain_wallet/services/wallet_service/wallet_service.dart';

import 'send_flow_test.mocks.dart';
import 'send_flow_test_constants.dart';

final get = GetIt.instance;

@GenerateMocks([
  AssetService,
  TransactionService,
  WalletService,
  TransactionHandler,
  PriceService,
])
main() {
  SendFlowState? state;
  Future<void> _build(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: SendFlow(walletDetails),
        ),
      ),
    );

    await tester
        .pump(Duration(milliseconds: 600)); // allow simulation timer to elapse.
    state = tester.allStates.firstWhere((element) => element is SendFlowState)
        as SendFlowState;
  }

  MockAssetService? mockAssetService;
  MockTransactionService? mockTransactionService;
  MockWalletService? mockWalletService;
  MockTransactionHandler? mockTransactionHandler;
  MockPriceService? mockPriceService;

  setUp(() {
    mockTransactionHandler = MockTransactionHandler();
    when(mockTransactionHandler!.estimateGas(any, any))
        .thenAnswer((realInvocation) {
      final gasEstimate = WalletGasEstimate(100, null);

      return Future.value(gasEstimate);
    });

    get.registerSingleton<TransactionHandler>(
      mockTransactionHandler!,
    );

    mockTransactionService = MockTransactionService();
    when(mockTransactionService!.getTransactions(
      any,
      any,
      any,
    )).thenAnswer((realInvocation) {
      final response = <Transaction>[];

      return Future.value(response);
    });

    mockAssetService = MockAssetService();
    when(mockAssetService!.getAssets(any, any)).thenAnswer((realInvocation) {
      final response = <Asset>[];

      return Future.value(response);
    });

    mockWalletService = MockWalletService();
    when(mockWalletService!.onDispose()).thenAnswer((_) => Future.value());

    mockPriceService = MockPriceService();
    when(mockPriceService!.getAssetPrices(any, any))
        .thenAnswer((realInvocation) => Future.value(<Price>[]));

    get.registerSingleton<TransactionService>(mockTransactionService!);
    get.registerSingleton<AssetService>(mockAssetService!);
    get.registerSingleton<WalletService>(mockWalletService!);
    get.registerSingleton<PriceService>(mockPriceService!);
  });

  tearDown(() {
    get.unregister<WalletService>();
    get.unregister<TransactionService>();
    get.unregister<AssetService>();
    get.unregister<TransactionHandler>();
    get.unregister<PriceService>();
  });

//   testWidgets("Contents", (tester) async {
//     await _build(tester);

//     expect(find.byType(SendScreen), findsOneWidget);
//   });

//   testWidgets("createStartPage", (tester) async {
//     await _build(tester);

//     expect(state!.createStartPage() is SendScreen, true);
//   });

//   group("SendBlocNavigator", () {
//     // fails due to not being able to load images
//     testWidgets("ScanAddress", (tester) async {
//       await _build(tester);
//       state!.scanAddress();
//       await tester.pumpAndSettle();

//       expect(find.byType(QRCodeScanner), findsOneWidget);
//     });

//   testWidgets("showAllRecentSends", (tester) async {
//     await _build(tester);
//     await state!.showAllRecentSends();
//     await tester.pumpAndSettle();

//     final dialogFind = find.byType(ErrorDialog);
//     expect(dialogFind, findsOneWidget);
//     expect(
//       find.descendant(
//         of: dialogFind,
//         matching: find.text("Not Implemented"),
//       ),
//       findsOneWidget,
//     );
//   });

//     testWidgets("showSelectAmount", (tester) async {
//       await _build(tester);

//       state!.showSelectAmount("Address", hashAsset);
//       await tester.pumpAndSettle();

//       expect(find.byType(SendAmountScreen), findsOneWidget);
//       final amountBloc = get<SendAmountBloc>();
//       expect(amountBloc.asset, hashAsset);
//       expect(amountBloc.receivingAddress, "Address");
//     });
//   });

//   group("SendAmountBlocNavigator", () {
//   failing due to NetworkImage not loading
//     testWidgets("showReviewSend", (tester) async {
//       await _build(tester);

//       state!.showSelectAmount("Address1", hashAsset); // needed to set the receiving address
//       await tester.pumpAndSettle();

//       state!.showReviewSend(dollarAsset, hashAsset, "Note",);
//       await tester.pumpAndSettle();

//       expect(find.byType(SendReviewScreen), findsOneWidget);
//       final bloc = get<SendReviewBloc>();
//       expect(bloc.sendingAsset, dollarAsset);
//       expect(bloc.fee, hashAsset);
//       expect(bloc.receivingAddress, "Address1");
//     });
//   });
}

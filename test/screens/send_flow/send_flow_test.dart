import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/account_service/model/account_gas_estimate.dart';
import 'package:provenance_wallet/services/account_service/transaction_handler.dart';
import 'package:provenance_wallet/services/asset_service/asset_service.dart';
import 'package:provenance_wallet/services/models/asset.dart';
import 'package:provenance_wallet/services/models/price.dart';
import 'package:provenance_wallet/services/models/transaction.dart';
import 'package:provenance_wallet/services/price_service/price_service.dart';
import 'package:provenance_wallet/services/transaction_service/transaction_service.dart';

import 'send_flow_test.mocks.dart';

final get = GetIt.instance;

@GenerateMocks([
  AssetService,
  TransactionService,
  AccountService,
  TransactionHandler,
  PriceService,
])
main() {
  MockAssetService? mockAssetService;
  MockTransactionService? mockTransactionService;
  MockAccountService? mockAccountService;
  MockTransactionHandler? mockTransactionHandler;
  MockPriceService? mockPriceService;

  setUp(() {
    mockTransactionHandler = MockTransactionHandler();
    when(mockTransactionHandler!.estimateGas(any, any))
        .thenAnswer((realInvocation) {
      final gasEstimate = AccountGasEstimate(100, null);

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

    mockAccountService = MockAccountService();
    when(mockAccountService!.onDispose()).thenAnswer((_) => Future.value());

    mockPriceService = MockPriceService();
    when(mockPriceService!.getAssetPrices(any, any))
        .thenAnswer((realInvocation) => Future.value(<Price>[]));

    get.registerSingleton<TransactionService>(mockTransactionService!);
    get.registerSingleton<AssetService>(mockAssetService!);
    get.registerSingleton<AccountService>(mockAccountService!);
    get.registerSingleton<PriceService>(mockPriceService!);
  });

  tearDown(() {
    get.unregister<AccountService>();
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

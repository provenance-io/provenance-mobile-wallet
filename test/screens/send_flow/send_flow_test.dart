import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provenance_wallet/common/models/asset.dart';
import 'package:provenance_wallet/common/models/transaction.dart';
import 'package:provenance_wallet/dialogs/error_dialog.dart';
import 'package:provenance_wallet/network/services/asset_service.dart';
import 'package:provenance_wallet/network/services/base_service.dart';
import 'package:provenance_wallet/network/services/transaction_service.dart';
import 'package:provenance_wallet/screens/qr_code_scanner.dart';
import 'package:provenance_wallet/screens/send_flow/send/send_screen.dart';
import 'package:provenance_wallet/screens/send_flow/send_amount/send_amount_screen.dart';
import 'package:provenance_wallet/screens/send_flow/send_amount/send_amount_bloc.dart';
import 'package:provenance_wallet/screens/send_flow/send_flow.dart';
import 'package:provenance_wallet/screens/send_flow/send_review/send_review_screen.dart';
import 'package:provenance_wallet/screens/send_flow/send_review/send_review_bloc.dart';
import 'package:provenance_wallet/services/wallet_service.dart';

import 'send_flow_test_constants.dart';
import 'send_flow_test.mocks.dart';

final get = GetIt.instance;

@GenerateMocks([ AssetService, TransactionService, WalletService, ])
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

    await tester.pump(Duration(milliseconds: 600)); // allow simulation timer to elapse.
    state = tester.allStates.firstWhere((element) => element is SendFlowState) as SendFlowState;
  }

  MockAssetService? mockAssetService;
  MockTransactionService? mockTransactionService;
  MockWalletService? mockWalletService;

  setUp(() {
    mockTransactionService = MockTransactionService();
    when(mockTransactionService!.getTransactions(any))
      .thenAnswer((realInvocation) {
        final response = BaseResponse<List<Transaction>>(null, null, null,);

        return Future.value(response);
      });

    mockAssetService = MockAssetService();
    when(mockAssetService!.getAssets(any))
      .thenAnswer((realInvocation) {
        final response = BaseResponse<List<Asset>>(null, null, null,);

        return Future.value(response);
      });

    mockWalletService = MockWalletService();
    when(mockWalletService!.estimate(any, any))
      .thenAnswer((realInvocation) {
        return Future.value(100);
      });

    get.registerSingleton<TransactionService>(mockTransactionService!);
    get.registerSingleton<AssetService>(mockAssetService!);
    get.registerSingleton<WalletService>(mockWalletService!);
  });

  tearDown(() {
    get.unregister<WalletService>();
    get.unregister<TransactionService>();
    get.unregister<AssetService>();
  });

  testWidgets("Contents", (tester) async {
    await _build(tester);

    expect(find.byType(SendScreen), findsOneWidget);
  });

  testWidgets("createStartPage", (tester) async {
    await _build(tester);

    expect(state!.createStartPage() is SendScreen, true);
  });

  group("SendBlocNavigator", () {
    // fails due to not being able to load images
    testWidgets("ScanAddress", (tester) async {
      await _build(tester);
      state!.scanAddress();
      await tester.pumpAndSettle();
    
      expect(find.byType(QRCodeScanner), findsOneWidget);
    });

    testWidgets("showAllRecentSends", (tester) async {
      await _build(tester);
      state!.showAllRecentSends();
      await tester.pumpAndSettle();

      final dialogFind = find.byType(ErrorDialog);
      expect(dialogFind, findsOneWidget);
      expect(find.descendant(of: dialogFind, matching: find.text("Not Implemented")), findsOneWidget);
    });
    
    testWidgets("showSelectAmount", (tester) async {
      await _build(tester);
    
      state!.showSelectAmount("Address", hashAsset);
      await tester.pumpAndSettle();
    
      expect(find.byType(SendAmountScreen), findsOneWidget);
      final amountBloc = get<SendAmountBloc>();
      expect(amountBloc.asset, hashAsset);
      expect(amountBloc.receivingAddress, "Address");
    });
  });

  // group("SendAmountBlocNavigator", () {
    // failing due to NetworkImage not loading
  //   testWidgets("showReviewSend", (tester) async {
  //     await _build(tester);
    
  //     state!.showSelectAmount("Address1", hashAsset); // needed to set the receiving address
  //     await tester.pumpAndSettle();

  //     state!.showReviewSend(dollarAsset, hashAsset, "Note",);      
  //     await tester.pumpAndSettle();

  //     expect(find.byType(SendReviewScreen), findsOneWidget);
  //     final bloc = get<SendReviewBloc>();
  //     expect(bloc.sendingAsset, dollarAsset);
  //     expect(bloc.fee, hashAsset);
  //     expect(bloc.receivingAddress, "Address1");
  //   });
  // });
}
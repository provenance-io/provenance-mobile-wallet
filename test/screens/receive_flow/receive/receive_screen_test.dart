import 'dart:async';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/screens/receive_flow/receive/receive_bloc.dart';
import 'package:provenance_wallet/screens/receive_flow/receive/receive_screen.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'receive_screen_test.mocks.dart';

final get = GetIt.instance;

@GenerateMocks([ReceiveBloc])
main() {
  MockReceiveBloc? mockBloc;
  StreamController<ReceiveState>? _streamController;

  setUp(() {
    _streamController = StreamController();
    _streamController!.add(ReceiveState(
      "WalletAddress",
    ));

    mockBloc = MockReceiveBloc();
    when(mockBloc!.stream).thenAnswer((_) => _streamController!.stream);
    when(mockBloc!.onDispose()).thenAnswer((_) => Future.value());
  });

  tearDown(() {
    _streamController!.close();
  });

  group("ReceiveScreen", () {
    Future<void> _build(WidgetTester tester) {
      return tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Provider<ReceiveBloc>(
            lazy: true,
            dispose: (_, bloc) => bloc.onDispose(),
            create: (context) {
              return mockBloc!;
            },
            child: ReceiveScreen(),
          ),
        ),
      );
    }

    testWidgets("Contents", (tester) async {
      await _build(tester);

      expect(find.byType(ReceivePage), findsOneWidget);
    });
  });

  group("ReceivePage", () {
    Future<void> _build(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Material(
            child: Provider<ReceiveBloc>(
              dispose: (_, bloc) => bloc.onDispose(),
              create: (context) {
                return mockBloc!;
              },
              child: ReceivePage(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
    }

    testWidgets("Contents", (tester) async {
      await _build(tester);

      final qrCodeFind = find.byType(QrImage);
      expect(qrCodeFind, findsOneWidget);

      expect(find.text("WalletAddress"), findsOneWidget);
      expect(find.byIcon(Icons.copy), findsOneWidget);
    });

    testWidgets("Copy button", (tester) async {
      when(mockBloc!.copyAddressToClipboard())
          .thenAnswer((_) => Future.value());

      await _build(tester);

      final copyFind = find.byIcon(Icons.copy);

      await tester.tap(copyFind);
      verify(mockBloc!.copyAddressToClipboard());

      await tester.pumpAndSettle();
      expect(
        find.text("Your address was copied to the clipboard"),
        findsOneWidget,
      );
    });

    testWidgets("Copy button -error", (tester) async {
      final ex = Exception("TEST");

      when(mockBloc!.copyAddressToClipboard())
          .thenAnswer((_) => Future.error(ex));

      await _build(tester);

      final copyFind = find.byIcon(Icons.copy);

      await tester.tap(copyFind);
      verify(mockBloc!.copyAddressToClipboard());

      await tester.pumpAndSettle();
      expect(
        find.text(ex.toString()),
        findsOneWidget,
      );
    });
  });
}

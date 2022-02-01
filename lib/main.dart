import 'package:flutter/material.dart';
import 'package:provenance_wallet/common/theme.dart';
import 'package:provenance_wallet/get.dart';
import 'package:provenance_wallet/screens/landing/landing.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:provenance_wallet/services/sample_wallet_connect_service.dart';
import 'package:provenance_wallet/services/sqlite_wallet_storage_service.dart';
import 'package:provenance_wallet/services/wallet_service.dart';
import 'package:provenance_wallet/util/router_observer.dart';

void main() {
  runApp(
    ProviderScope(
      child: WalletApp(),
    ),
  );
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class WalletApp extends StatefulWidget {
  const WalletApp({Key? key}) : super(key: key);

  @override
  _WalletAppState createState() => _WalletAppState();
}

class _WalletAppState extends State<WalletApp> {
  @override
  void initState() {
    super.initState();

    get.registerLazySingleton<WalletService>(
      () => WalletService(
        storage: SqliteWalletStorageService(),
        connect: SampleWalletConnectService(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Provenance Wallet',
      theme: FigurePayThemeData.themeData,
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      navigatorObservers: [RouterObserver.instance.routeObserver],
      home: Landing(),
    );
  }
}

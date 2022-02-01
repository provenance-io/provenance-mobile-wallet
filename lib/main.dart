import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provenance_wallet/common/theme.dart';
import 'package:provenance_wallet/firebase_options.dart';
import 'package:provenance_wallet/network/services/asset_service.dart';
import 'package:provenance_wallet/network/services/stat_service.dart';
import 'package:provenance_wallet/network/services/transaction_service.dart';
import 'package:provenance_wallet/screens/landing/landing.dart';
import 'package:provenance_wallet/services/sample_wallet_connect_service.dart';
import 'package:provenance_wallet/services/sqlite_wallet_storage_service.dart';
import 'package:provenance_wallet/services/wallet_service.dart';
import 'package:provenance_wallet/util/router_observer.dart';
import 'package:provenance_wallet/util/strings.dart';

import 'util/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ProvenanceWalletApp(),
  );
}

class ProvenanceWalletApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ProvenanceWalletAppState();
}

class _ProvenanceWalletAppState extends State<ProvenanceWalletApp> {
  @override
  void initState() {
    super.initState();

    get.registerLazySingleton<StatService>(
      () => StatService(),
    );
    get.registerLazySingleton<AssetService>(
      () => AssetService(),
    );
    get.registerLazySingleton<TransactionService>(
      () => TransactionService(),
    );

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
      title: Strings.appName,
      theme: FigurePayThemeData.themeData,
      debugShowCheckedModeBanner: false,
      navigatorObservers: [
        RouterObserver.instance.routeObserver,
      ],
      home: Landing(),
    );
  }
}

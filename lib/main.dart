import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prov_wallet_flutter/prov_wallet_flutter.dart';
import 'package:provenance_wallet/common/theme.dart';
import 'package:provenance_wallet/firebase_options.dart';
import 'package:provenance_wallet/network/services/asset_service.dart';
import 'package:provenance_wallet/network/services/stat_service.dart';
import 'package:provenance_wallet/network/services/transaction_service.dart';
import 'package:provenance_wallet/screens/landing/landing_screen.dart';
import 'package:provenance_wallet/services/sqlite_wallet_storage_service.dart';
import 'package:provenance_wallet/services/wallet_service.dart';
import 'package:provenance_wallet/services/wallet_storage_service_imp.dart';
import 'package:provenance_wallet/util/router_observer.dart';
import 'package:provenance_wallet/util/strings.dart';

import 'util/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp],
  );
  runApp(
    ProvenanceWalletApp(),
  );
}

class ProvenanceWalletApp extends StatefulWidget {
  const ProvenanceWalletApp({
    Key? key,
  }) : super(key: key);

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

    final cipherService = CipherService();
    final sqliteStorage = SqliteWalletStorageService();
    final walletStorage = WalletStorageServiceImp(sqliteStorage, cipherService);

    get.registerLazySingleton<WalletService>(
      () => WalletService(
        storage: walletStorage,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Strings.appName,
      theme: ProvenanceThemeData.themeData,
      debugShowCheckedModeBanner: false,
      navigatorObservers: [
        RouterObserver.instance.routeObserver,
      ],
      home: LandingScreen(),
    );
  }
}

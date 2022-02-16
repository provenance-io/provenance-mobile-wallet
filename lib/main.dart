import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provenance_wallet/common/theme.dart';
import 'package:provenance_wallet/firebase_options.dart';
import 'package:provenance_wallet/network/services/asset_service.dart';
import 'package:provenance_wallet/network/services/stat_service.dart';
import 'package:provenance_wallet/network/services/transaction_service.dart';
import 'package:provenance_wallet/screens/landing/landing_screen.dart';
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
      home: LandingScreen(),
    );
  }
}

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prov_wallet_flutter/prov_wallet_flutter.dart';
import 'package:provenance_wallet/common/theme.dart';
import 'package:provenance_wallet/firebase_options.dart';
import 'package:provenance_wallet/screens/landing/landing_screen.dart';
import 'package:provenance_wallet/services/asset_service/asset_service.dart';
import 'package:provenance_wallet/services/asset_service/default_asset_service.dart';
import 'package:provenance_wallet/services/deep_link/deep_link_service.dart';
import 'package:provenance_wallet/services/deep_link/firebase_deep_link_service.dart';
import 'package:provenance_wallet/services/http_client.dart';
import 'package:provenance_wallet/services/notification/basic_notification_service.dart';
import 'package:provenance_wallet/services/notification/notification_service.dart';
import 'package:provenance_wallet/services/secure_storage_service.dart';
import 'package:provenance_wallet/services/shared_prefs_service.dart';
import 'package:provenance_wallet/services/sqlite_wallet_storage_service.dart';
import 'package:provenance_wallet/services/stat_service/default_stat_service.dart';
import 'package:provenance_wallet/services/stat_service/stat_service.dart';
import 'package:provenance_wallet/services/transaction_service/default_transaction_service.dart';
import 'package:provenance_wallet/services/transaction_service/transaction_service.dart';
import 'package:provenance_wallet/services/wallet_service/wallet_service.dart';
import 'package:provenance_wallet/services/wallet_service/wallet_storage_service_imp.dart';
import 'package:provenance_wallet/util/local_auth_helper.dart';
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

  var sharedPrefs = SharedPrefsService();
  var hasKey = await sharedPrefs.containsKey(PrefKey.isSubsequentRun);
  if (!hasKey) {
    await SecureStorageService().deleteAll();
    sharedPrefs.setBool(PrefKey.isSubsequentRun, true);
  }

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

    get.registerLazySingleton<HttpClient>(
      () => HttpClient(),
    );
    get.registerLazySingleton<SecureStorageService>(
      () => SecureStorageService(),
    );
    get.registerLazySingleton<LocalAuthHelper>(
      () => LocalAuthHelper()..initialize(),
    );
    get.registerLazySingleton<StatService>(
      () => DefaultStatService(),
    );
    get.registerLazySingleton<AssetService>(
      () => DefaultAssetService(),
    );
    get.registerLazySingleton<TransactionService>(
      () => DefaultTransactionService(),
    );
    get.registerLazySingleton<NotificationService>(
      () => BasicNotificationService(),
    );

    final cipherService = CipherService();
    final sqliteStorage = SqliteWalletStorageService();
    final walletStorage = WalletStorageServiceImp(sqliteStorage, cipherService);

    get.registerLazySingleton<WalletService>(
      () => WalletService(
        storage: walletStorage,
      ),
    );

    final deepLinkService = FirebaseDeepLinkService()..init();
    get.registerSingleton<DeepLinkService>(deepLinkService);
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

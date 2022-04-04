import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:prov_wallet_flutter/prov_wallet_flutter.dart';
import 'package:provenance_dart/wallet_connect.dart';
import 'package:provenance_wallet/common/theme.dart';
import 'package:provenance_wallet/screens/dashboard/dashboard_bloc.dart';
import 'package:provenance_wallet/screens/landing/landing_screen.dart';
import 'package:provenance_wallet/services/asset_service/asset_service.dart';
import 'package:provenance_wallet/services/asset_service/default_asset_service.dart';
import 'package:provenance_wallet/services/asset_service/mock_asset_service.dart';
import 'package:provenance_wallet/services/connectivity/connectivity_service.dart';
import 'package:provenance_wallet/services/connectivity/default_connectivity_service.dart';
import 'package:provenance_wallet/services/deep_link/deep_link_service.dart';
import 'package:provenance_wallet/services/deep_link/firebase_deep_link_service.dart';
import 'package:provenance_wallet/services/gas_fee_service/default_gas_fee_service.dart';
import 'package:provenance_wallet/services/gas_fee_service/gas_fee_service.dart';
import 'package:provenance_wallet/services/http_client.dart';
import 'package:provenance_wallet/services/key_value_service.dart';
import 'package:provenance_wallet/services/notification/basic_notification_service.dart';
import 'package:provenance_wallet/services/notification/notification_info.dart';
import 'package:provenance_wallet/services/notification/notification_kind.dart';
import 'package:provenance_wallet/services/notification/notification_service.dart';
import 'package:provenance_wallet/services/platform_key_value_service.dart';
import 'package:provenance_wallet/services/price_service/price_service.dart';
import 'package:provenance_wallet/services/remote_notification/default_remote_notification_service.dart';
import 'package:provenance_wallet/services/remote_notification/remote_notification_service.dart';
import 'package:provenance_wallet/services/sqlite_wallet_storage_service.dart';
import 'package:provenance_wallet/services/stat_service/default_stat_service.dart';
import 'package:provenance_wallet/services/stat_service/stat_service.dart';
import 'package:provenance_wallet/services/transaction_service/default_transaction_service.dart';
import 'package:provenance_wallet/services/transaction_service/mock_transaction_service.dart';
import 'package:provenance_wallet/services/transaction_service/transaction_service.dart';
import 'package:provenance_wallet/services/wallet_service/wallet_connect_transaction_handler.dart';
import 'package:provenance_wallet/services/wallet_service/wallet_service.dart';
import 'package:provenance_wallet/services/wallet_service/wallet_storage_service_imp.dart';
import 'package:provenance_wallet/util/local_auth_helper.dart';
import 'package:provenance_wallet/util/push_notification_helper.dart';
import 'package:provenance_wallet/util/router_observer.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:rxdart/rxdart.dart';

import 'util/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  await SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp],
  );

  final firebaseMessaging = FirebaseMessaging.instance;
  final pushNotificationHelper = PushNotificationHelper(firebaseMessaging);
  await pushNotificationHelper.init();

  get.registerLazySingleton<RemoteNotificationService>(() {
    return DefaultRemoteNotificationService(pushNotificationHelper);
  });

  final cipherService = PlatformCipherService();
  get.registerSingleton<CipherService>(cipherService);

  var keyValueService = PlatformKeyValueService();
  var hasKey = await keyValueService.containsKey(PrefKey.isSubsequentRun);
  if (!hasKey) {
    await cipherService.deletePin();
    keyValueService.setBool(PrefKey.isSubsequentRun, true);
  }

  get.registerSingleton<KeyValueService>(keyValueService);
  final sqliteStorage = SqliteWalletStorageService();
  final walletStorage = WalletStorageServiceImp(sqliteStorage, cipherService);

  get.registerLazySingleton<WalletService>(
    () => WalletService(
      storage: walletStorage,
    ),
  );

  final authHelper = LocalAuthHelper();
  await authHelper.init();

  get.registerSingleton<LocalAuthHelper>(authHelper);

  runApp(
    Phoenix(
      child: ProvenanceWalletApp(),
    ),
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
  _ProvenanceWalletAppState() {
    _setup();
  }

  final _subscriptions = CompositeSubscription();
  final _navigatorKey = GlobalKey<NavigatorState>();
  var _authStatus = AuthStatus.noAccount;

  @override
  void dispose() {
    _subscriptions.dispose();
    super.dispose();
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
      navigatorKey: _navigatorKey,
    );
  }

  Future<void> _setup() async {
    final keyValueService = get<KeyValueService>();

    final authHelper = get<LocalAuthHelper>();
    _authStatus = authHelper.status.value;

    authHelper.status.listen((e) {
      final previousStatus = _authStatus;
      _authStatus = e;

      switch (e) {
        case AuthStatus.unauthenticated:
          break;
        case AuthStatus.authenticated:
          break;
        case AuthStatus.noAccount:
        case AuthStatus.noWallet:
        case AuthStatus.noLockScreen:
        case AuthStatus.timedOut:
          if (previousStatus == AuthStatus.authenticated) {
            _navigatorKey.currentState?.popUntil((route) => route.isFirst);
          }
          break;
      }
    }).addTo(_subscriptions);

    get.registerLazySingleton<HttpClient>(
      () => HttpClient(),
    );

    keyValueService.streamBool(PrefKey.httpClientDiagnostics500).listen((e) {
      final doError = e ?? false;
      final client = get<HttpClient>();
      final statusCode = doError ? HttpStatus.internalServerError : null;
      client.setDiagnosticsError(statusCode);
    }).addTo(_subscriptions);

    get.registerLazySingleton<StatService>(
      () => DefaultStatService(),
    );
    final isMockingAssetService =
        await keyValueService.getBool(PrefKey.isMockingAssetService) ?? false;

    get.registerLazySingleton<AssetService>(
      () => isMockingAssetService ? MockAssetService() : DefaultAssetService(),
    );

    final isMockingTransactionService =
        await keyValueService.getBool(PrefKey.isMockingTransactionService) ??
            false;

    get.registerLazySingleton<TransactionService>(
      () => isMockingTransactionService
          ? MockTransactionService()
          : DefaultTransactionService(),
    );
    get.registerLazySingleton<ConnectivityService>(
      () => DefaultConnectivityService(),
    );
    get<ConnectivityService>().isConnected.distinct().listen((isConnected) {
      final notificationService = get<NotificationService>();
      const networkDisconnectedId = "networkDisconnected";
      if (!isConnected) {
        notificationService.notify(NotificationInfo(
          id: networkDisconnectedId,
          title: Strings.notifyNetworkErrorTitle,
          message: Strings.notifyNetworkErrorMessage,
          kind: NotificationKind.warn,
        ));
      } else {
        notificationService.dismiss(networkDisconnectedId);
      }
    }).addTo(_subscriptions);

    get.registerLazySingleton<NotificationService>(
      () => BasicNotificationService(),
    );
    get.registerLazySingleton<GasFeeService>(
      () => DefaultGasFeeService(),
    );
    get.registerLazySingleton<WalletConnectionFactory>(
      () => (address) => WalletConnection(address),
    );
    get.registerLazySingleton<WalletConnectTransactionHandler>(
      () => WalletConnectTransactionHandler(),
    );

    get.registerLazySingleton<PriceService>(
      () => PriceService(),
    );

    final deepLinkService = FirebaseDeepLinkService()..init();
    get.registerSingleton<DeepLinkService>(deepLinkService);
  }
}

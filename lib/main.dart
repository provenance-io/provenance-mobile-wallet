import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart'
    show FirebaseRemoteConfig;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:prov_wallet_flutter/prov_wallet_flutter.dart';
import 'package:provenance_dart/proto.dart';
import 'package:provenance_dart/wallet_connect.dart';
import 'package:provenance_wallet/chain_id.dart';
import 'package:provenance_wallet/common/theme.dart';
import 'package:provenance_wallet/common/widgets/pw_dialog.dart';
import 'package:provenance_wallet/screens/home/home_bloc.dart';
import 'package:provenance_wallet/screens/landing/landing_screen.dart';
import 'package:provenance_wallet/services/asset_service/asset_service.dart';
import 'package:provenance_wallet/services/asset_service/default_asset_service.dart';
import 'package:provenance_wallet/services/asset_service/mock_asset_service.dart';
import 'package:provenance_wallet/services/config_service/config_service.dart';
import 'package:provenance_wallet/services/config_service/default_config_service.dart';
import 'package:provenance_wallet/services/config_service/local_config.dart';
import 'package:provenance_wallet/services/connectivity/connectivity_service.dart';
import 'package:provenance_wallet/services/connectivity/default_connectivity_service.dart';
import 'package:provenance_wallet/services/crash_reporting/crash_reporting_service.dart';
import 'package:provenance_wallet/services/crash_reporting/firebase_crash_reporting_service.dart';
import 'package:provenance_wallet/services/deep_link/deep_link_service.dart';
import 'package:provenance_wallet/services/deep_link/firebase_deep_link_service.dart';
import 'package:provenance_wallet/services/gas_fee_service/default_gas_fee_service.dart';
import 'package:provenance_wallet/services/gas_fee_service/gas_fee_service.dart';
import 'package:provenance_wallet/services/http_client.dart';
import 'package:provenance_wallet/services/key_value_service/default_key_value_service.dart';
import 'package:provenance_wallet/services/key_value_service/key_value_service.dart';
import 'package:provenance_wallet/services/key_value_service/shared_preferences_key_value_store.dart';
import 'package:provenance_wallet/services/notification/basic_notification_service.dart';
import 'package:provenance_wallet/services/notification/notification_info.dart';
import 'package:provenance_wallet/services/notification/notification_kind.dart';
import 'package:provenance_wallet/services/notification/notification_service.dart';
import 'package:provenance_wallet/services/price_service/price_service.dart';
import 'package:provenance_wallet/services/remote_notification/default_remote_notification_service.dart';
import 'package:provenance_wallet/services/remote_notification/remote_notification_service.dart';
import 'package:provenance_wallet/services/sqlite_wallet_storage_service.dart';
import 'package:provenance_wallet/services/stat_service/default_stat_service.dart';
import 'package:provenance_wallet/services/stat_service/stat_service.dart';
import 'package:provenance_wallet/services/transaction_service/default_transaction_service.dart';
import 'package:provenance_wallet/services/transaction_service/mock_transaction_service.dart';
import 'package:provenance_wallet/services/transaction_service/transaction_service.dart';
import 'package:provenance_wallet/services/wallet_service/default_transaction_handler.dart';
import 'package:provenance_wallet/services/wallet_service/transaction_handler.dart';
import 'package:provenance_wallet/services/wallet_service/wallet_service.dart';
import 'package:provenance_wallet/services/wallet_service/wallet_storage_service_imp.dart';
import 'package:provenance_wallet/util/local_auth_helper.dart';
import 'package:provenance_wallet/util/logs/logging.dart';
import 'package:provenance_wallet/util/push_notification_helper.dart';
import 'package:provenance_wallet/util/router_observer.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:rxdart/rxdart.dart';

import 'util/get.dart';

// Toggle this for testing Crashlytics in your app locally.
const _testingCrashlytics = false;
const _tag = 'main';

void main() {
  final originalOnError = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails errorDetails) {
    originalOnError?.call(errorDetails);
    FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
  };
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp();

      await SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp],
      );

      get.registerLazySingleton<CrashReportingService>(
        () => FirebaseCrashReportingService(),
      );

      var keyValueService = DefaultKeyValueService(
        store: SharedPreferencesKeyValueStore(),
      );

      await _initializeCrashlytics(keyValueService);

      final firebaseMessaging = FirebaseMessaging.instance;
      final pushNotificationHelper = PushNotificationHelper(firebaseMessaging);

      get.registerLazySingleton<RemoteNotificationService>(() {
        return DefaultRemoteNotificationService(pushNotificationHelper);
      });

      final cipherService = PlatformCipherService();
      get.registerSingleton<CipherService>(cipherService);

      var hasKey = await keyValueService.containsKey(PrefKey.isSubsequentRun);
      if (!hasKey) {
        await cipherService.deletePin();
        keyValueService.setBool(PrefKey.isSubsequentRun, true);
      }

      final configService = DefaultConfigService(
        keyValueService: keyValueService,
        firebaseRemoteConfig: FirebaseRemoteConfig.instance,
      );
      get.registerSingleton<ConfigService>(configService);

      final config = await configService.getLocalConfig();
      get.registerSingleton<LocalConfig>(config);

      logStatic(
        _tag,
        Level.info,
        'Initializing: $config',
      );

      get.registerSingleton<KeyValueService>(keyValueService);
      final sqliteStorage = SqliteWalletStorageService();
      final walletStorage =
          WalletStorageServiceImp(sqliteStorage, cipherService);

      final walletService = WalletService(storage: walletStorage)..init();
      get.registerSingleton<WalletService>(walletService);

      get.registerSingleton<LocalAuthHelper>(LocalAuthHelper());

      runApp(
        Phoenix(
          child: ProvenanceWalletApp(),
        ),
      );
    },
    (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack);
    },
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

    get<CipherService>().error.listen((e) {
      logDebug("CipherService error: $e");

      final navContext = _navigatorKey.currentContext;
      if (navContext != null) {
        showCipherServiceError(navContext, e);
      }
    }).addTo(_subscriptions);

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

    final configService = get<ConfigService>();
    final remoteConfig = configService.getRemoteConfig();

    get.registerSingleton<ProtobuffClientInjector>(
      (coin) => remoteConfig.then(
        (value) => PbClient(
          Uri.parse(value.endpoints.chain.forCoin(coin)),
          ChainId.forCoin(
            coin,
          ),
        ),
      ),
    );

    get.registerSingleton<Future<MainHttpClient>>(
      remoteConfig.then(
        (value) => MainHttpClient(
          baseUrl: value.endpoints.figureTech.mainUrl,
        ),
      ),
    );

    get.registerSingleton<Future<TestHttpClient>>(
      remoteConfig.then(
        (value) => TestHttpClient(
          baseUrl: value.endpoints.figureTech.testUrl,
        ),
      ),
    );

    keyValueService
        .stream<bool>(PrefKey.httpClientDiagnostics500)
        .listen((e) async {
      final doError = e.data ?? false;
      final statusCode = doError ? HttpStatus.internalServerError : null;

      (await get<Future<MainHttpClient>>()).setDiagnosticsError(statusCode);
      (await get<Future<TestHttpClient>>()).setDiagnosticsError(statusCode);
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
    get.registerLazySingleton<TransactionHandler>(
      () => DefaultTransactionHandler(),
    );

    get.registerLazySingleton<PriceService>(
      () => PriceService(),
    );

    final deepLinkService = FirebaseDeepLinkService()..init();
    get.registerSingleton<DeepLinkService>(deepLinkService);
  }
}

Future<void> _initializeCrashlytics(KeyValueService service) async {
  final allowCrashlytics = _testingCrashlytics ||
      ((await service.getBool(PrefKey.allowCrashlitics) ?? true) &&
          !kDebugMode);
  await FirebaseCrashlytics.instance
      .setCrashlyticsCollectionEnabled(allowCrashlytics);
}

void showCipherServiceError(BuildContext context, CipherServiceError error) {
  String message;
  switch (error.code) {
    case CipherServiceErrorCode.accessError:
      message = Strings.cipherAccessError;
      break;
    case CipherServiceErrorCode.accountKeyNotFound:
      message = Strings.cipherAccountKeyNotFoundError;
      break;
    case CipherServiceErrorCode.addSecItem:
      message = Strings.cipherAddSecItemError;
      break;
    case CipherServiceErrorCode.dataPersistence:
      message = Strings.cipherDataPersistenceError;
      break;
    case CipherServiceErrorCode.invalidArgument:
      message = Strings.cipherInvalidArgumentError;
      break;
    case CipherServiceErrorCode.publicKeyError:
      message = Strings.cipherPublicKeyError;
      break;
    case CipherServiceErrorCode.secKeyNotFound:
      message = Strings.cipherSecKeyNotFoundError;
      break;
    case CipherServiceErrorCode.unknown:
      message = Strings.cipherUnknownError;
      break;
    case CipherServiceErrorCode.upgradeError:
      message = Strings.cipherUpgradeError;
      break;
    case CipherServiceErrorCode.unsupportedAlgorithm:
      message = Strings.cipherUnsupportedAlgorithmError;
      break;
  }

  PwDialog.showError(
    context,
    title: Strings.cipherErrorTitle,
    message: message,
  );
}

import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:path_provider/path_provider.dart';
import 'package:prov_wallet_flutter/prov_wallet_flutter.dart';
import 'package:provenance_dart/proto.dart';
import 'package:provenance_dart/wallet.dart' as wallet;
import 'package:provenance_dart/wallet_connect.dart';
import 'package:provenance_wallet/chain_id.dart';
import 'package:provenance_wallet/common/theme.dart';
import 'package:provenance_wallet/common/widgets/pw_dialog.dart';
import 'package:provenance_wallet/screens/start_screen.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/account_service/account_storage_service.dart';
import 'package:provenance_wallet/services/account_service/account_storage_service_imp.dart';
import 'package:provenance_wallet/services/account_service/account_storage_service_kind.dart';
import 'package:provenance_wallet/services/account_service/default_transaction_handler.dart';
import 'package:provenance_wallet/services/account_service/sembast_account_storage_service.dart';
import 'package:provenance_wallet/services/account_service/transaction_handler.dart';
import 'package:provenance_wallet/services/asset_service/asset_service.dart';
import 'package:provenance_wallet/services/asset_service/default_asset_service.dart';
import 'package:provenance_wallet/services/asset_service/mock_asset_service.dart';
import 'package:provenance_wallet/services/config_service/default_local_config_service.dart';
import 'package:provenance_wallet/services/config_service/default_remote_config_service.dart';
import 'package:provenance_wallet/services/config_service/firebase_remote_config_service.dart';
import 'package:provenance_wallet/services/config_service/local_config.dart';
import 'package:provenance_wallet/services/config_service/remote_config_service.dart';
import 'package:provenance_wallet/services/connectivity/connectivity_service.dart';
import 'package:provenance_wallet/services/connectivity/default_connectivity_service.dart';
import 'package:provenance_wallet/services/crash_reporting/crash_reporting_service.dart';
import 'package:provenance_wallet/services/crash_reporting/firebase_crash_reporting_service.dart';
import 'package:provenance_wallet/services/crash_reporting/logging_crash_reporting_service.dart';
import 'package:provenance_wallet/services/deep_link/deep_link_service.dart';
import 'package:provenance_wallet/services/deep_link/disabled_deep_link_service.dart';
import 'package:provenance_wallet/services/deep_link/firebase_deep_link_service.dart';
import 'package:provenance_wallet/services/gas_fee_service/default_gas_fee_service.dart';
import 'package:provenance_wallet/services/gas_fee_service/gas_fee_service.dart';
import 'package:provenance_wallet/services/governance_service/default_governance_service.dart';
import 'package:provenance_wallet/services/governance_service/governance_service.dart';
import 'package:provenance_wallet/services/http_client.dart';
import 'package:provenance_wallet/services/key_value_service/default_key_value_service.dart';
import 'package:provenance_wallet/services/key_value_service/key_value_service.dart';
import 'package:provenance_wallet/services/key_value_service/shared_preferences_key_value_store.dart';
import 'package:provenance_wallet/services/multi_sig_service/multi_sig_service.dart';
import 'package:provenance_wallet/services/notification/basic_notification_service.dart';
import 'package:provenance_wallet/services/notification/notification_info.dart';
import 'package:provenance_wallet/services/notification/notification_kind.dart';
import 'package:provenance_wallet/services/notification/notification_service.dart';
import 'package:provenance_wallet/services/price_service/price_service.dart';
import 'package:provenance_wallet/services/remote_notification/default_remote_notification_service.dart';
import 'package:provenance_wallet/services/remote_notification/disabled_remote_notification_service.dart';
import 'package:provenance_wallet/services/remote_notification/remote_notification_service.dart';
import 'package:provenance_wallet/services/sqlite_account_storage_service.dart';
import 'package:provenance_wallet/services/stat_service/default_stat_service.dart';
import 'package:provenance_wallet/services/stat_service/stat_service.dart';
import 'package:provenance_wallet/services/transaction_service/default_transaction_service.dart';
import 'package:provenance_wallet/services/transaction_service/mock_transaction_service.dart';
import 'package:provenance_wallet/services/transaction_service/transaction_service.dart';
import 'package:provenance_wallet/services/validator_service/default_validator_service.dart';
import 'package:provenance_wallet/services/validator_service/mock_validator_service.dart';
import 'package:provenance_wallet/services/validator_service/validator_service.dart';
import 'package:provenance_wallet/services/wallet_connect_queue_service/wallet_connect_queue_service.dart';
import 'package:provenance_wallet/services/wallet_connect_service/default_wallet_connect_service.dart';
import 'package:provenance_wallet/services/wallet_connect_service/wallet_connect_service.dart';
import 'package:provenance_wallet/util/local_auth_helper.dart';
import 'package:provenance_wallet/util/logs/logging.dart';
import 'package:provenance_wallet/util/router_observer.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast/sembast_memory.dart';

import 'util/get.dart';

// Toggle this for testing crash reporting in your app locally.
const _testingCrashReporting = false;
const _tag = 'main';

const _cipherServiceKind = String.fromEnvironment(
  'CIPHER_SERVICE',
  defaultValue: 'platform',
);
const _accountServiceKind = String.fromEnvironment(
  'ACCOUNT_STORAGE',
  defaultValue: 'sembast',
);
const _enableFirebase = bool.fromEnvironment(
  'ENABLE_FIREBASE',
  defaultValue: true,
);

final _log = Log.instance;

void main() {
  final originalOnError = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails errorDetails) {
    originalOnError?.call(errorDetails);
    if (get.isRegistered<CrashReportingService>()) {
      get<CrashReportingService>().recordFlutterError(errorDetails);
    }
  };
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      await SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp],
      );

      final keyValueService = DefaultKeyValueService(
        store: SharedPreferencesKeyValueStore(),
      );

      get.registerSingleton<KeyValueService>(keyValueService);

      final localConfigService = DefaultLocalConfigService();
      final config = await localConfigService.getConfig();
      get.registerSingleton<LocalConfig>(config);

      _log.info('Initializing: $config', tag: _tag);

      CrashReportingService crashReportingService;
      RemoteNotificationService remoteNotificationService;
      RemoteConfigService remoteConfigService;
      DeepLinkService deepLinkService;

      _log.info('Enable Firebase: $_enableFirebase', tag: _tag);

      if (_enableFirebase) {
        await Firebase.initializeApp();

        crashReportingService = FirebaseCrashReportingService();

        remoteNotificationService = DefaultRemoteNotificationService();
        remoteConfigService = FirebaseRemoteConfigService(
          keyValueService: keyValueService,
          localConfigService: localConfigService,
        );
        deepLinkService = FirebaseDeepLinkService()..init();
      } else {
        crashReportingService = LoggingCrashReportingService();
        remoteNotificationService = DisabledRemoteNotificationService();
        remoteConfigService = DefaultRemoteConfigService(
          localConfigService: localConfigService,
        );
        deepLinkService = DisabledDeepLinkService();
      }

      get.registerSingleton<CrashReportingService>(
        crashReportingService,
      );

      final allowCrashReporting = _testingCrashReporting ||
          ((await keyValueService.getBool(PrefKey.allowCrashlitics) ?? true) &&
              !kDebugMode);

      await crashReportingService.enableCrashCollection(
        enable: allowCrashReporting,
      );

      get.registerSingleton<RemoteNotificationService>(
        remoteNotificationService,
      );

      get.registerSingleton<RemoteConfigService>(
        remoteConfigService,
      );

      get.registerSingleton<DeepLinkService>(deepLinkService);

      CipherService cipherService;

      switch (CipherServiceKind.values.byName(_cipherServiceKind)) {
        case CipherServiceKind.platform:
          cipherService = PlatformCipherService();
          break;
        case CipherServiceKind.memory:
          cipherService = MemoryCipherService();
          break;
      }

      get.registerSingleton<CipherService>(cipherService);
      _log.info(
        '$CipherService implementation: ${cipherService.runtimeType}',
        tag: _tag,
      );

      var hasKey = await keyValueService.containsKey(PrefKey.isSubsequentRun);
      if (!hasKey) {
        await cipherService.deletePin();
        keyValueService.setBool(PrefKey.isSubsequentRun, true);
      }

      AccountStorageService accountStorageService;

      switch (AccountStorageServiceKind.values.byName(_accountServiceKind)) {
        case AccountStorageServiceKind.sembast:
          final directory = await getApplicationDocumentsDirectory();
          await directory.create(recursive: true);
          final serviceCore = SembastAccountStorageService(
            factory: databaseFactoryIo,
            directory: directory.absolute.path,
          );
          accountStorageService =
              AccountStorageServiceImp(serviceCore, cipherService);

          await _migrateSqlite(accountStorageService, cipherService);

          break;
        case AccountStorageServiceKind.memory:
          final serviceCore = SembastAccountStorageService(
            factory: databaseFactoryMemory,
            directory: sembastInMemoryDatabasePath,
          );
          accountStorageService = AccountStorageServiceImp(
            serviceCore,
            cipherService,
          );
          break;
      }

      _log.info(
        '$AccountStorageService implementation: ${accountStorageService.runtimeType}',
        tag: _tag,
      );

      final accountService = AccountService(storage: accountStorageService);
      get.registerSingleton<AccountService>(accountService);

      get.registerSingleton<LocalAuthHelper>(LocalAuthHelper());
      get.registerLazySingleton<MultiSigService>(() => MultiSigService());

      get.registerSingleton<WalletConnectQueueService>(
          WalletConnectQueueService());

      runApp(
        Phoenix(
          child: ProvenanceWalletApp(),
        ),
      );
    },
    (error, stack) {
      if (get.isRegistered<CrashReportingService>()) {
        get<CrashReportingService>().recordError(
          error,
          stack: stack,
        );
      } else {
        _log.error(
          'Error occurred',
          tag: _tag,
          error: error,
          stack: stack,
        );
      }
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
      onGenerateTitle: (context) => Strings.of(context).appName,
      theme: ProvenanceThemeData.themeData,
      debugShowCheckedModeBanner: false,
      navigatorObservers: [
        RouterObserver.instance.routeObserver,
      ],
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: StartScreen(),
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
        case AuthStatus.noLockScreen:
        case AuthStatus.timedOut:
          if (previousStatus == AuthStatus.authenticated) {
            _navigatorKey.currentState?.popUntil((route) => route.isFirst);
          }
          break;
      }
    }).addTo(_subscriptions);

    final configService = get<RemoteConfigService>();
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

    final isMockingValidatorService =
        await keyValueService.getBool(PrefKey.isMockingValidatorService) ??
            false;

    get.registerLazySingleton<ValidatorService>(
      () => isMockingValidatorService
          ? MockValidatorService()
          : DefaultValidatorService(),
    );

    // final isMockingGovernanceService =
    //     await keyValueService.getBool(PrefKey.isMockingGovernanceService) ??
    //         false;
    get.registerLazySingleton<GovernanceService>(
      () => //isMockingGovernanceService
          //? MockGovernanceService() :
          DefaultGovernanceService(),
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
          title: BasicNotificationServiceStrings.notifyNetworkErrorTitle,
          message: BasicNotificationServiceStrings.notifyNetworkErrorMessage,
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

    get.registerSingleton<WalletConnectService>(DefaultWalletConnectService());

    final accountService = get<AccountService>();
    final remoteNotificationService = get<RemoteNotificationService>();

    final accounts = await accountService.getAccounts();
    for (var account in accounts) {
      final address = account.publicKey?.address;
      if (address != null) {
        await remoteNotificationService.registerForPushNotifications(address);
      }
    }

    accountService.events.added.listen((e) {
      final address = e.publicKey?.address;
      if (address != null) {
        remoteNotificationService.registerForPushNotifications(address).onError(
              (error, stackTrace) => logDebug(
                'Add event failed to register for push notifications for account: $address',
              ),
            );
      }
    }).addTo(_subscriptions);

    accountService.events.removed.listen((e) {
      for (var account in e) {
        final address = account.publicKey?.address;
        if (address != null) {
          remoteNotificationService
              .unregisterForPushNotifications(address)
              .onError(
                (error, stackTrace) => logDebug(
                  'Remove event failed to unregister push notifications for account: $address',
                ),
              );
        }
      }
    }).addTo(_subscriptions);

    accountService.events.updated.listen((e) {
      final address = e.publicKey?.address;
      if (address != null && !remoteNotificationService.isRegistered(address)) {
        remoteNotificationService.registerForPushNotifications(address).onError(
              (error, stackTrace) => logDebug(
                'Update event failed to register for push notifications for account: $address',
              ),
            );
      }
    }).addTo(_subscriptions);
  }
}

void showCipherServiceError(BuildContext context, CipherServiceError error) {
  String message;
  switch (error.code) {
    case CipherServiceErrorCode.accessError:
      message = Strings.of(context).cipherAccessError;
      break;
    case CipherServiceErrorCode.accountKeyNotFound:
      message = Strings.of(context).cipherAccountKeyNotFoundError;
      break;
    case CipherServiceErrorCode.addSecItem:
      message = Strings.of(context).cipherAddSecItemError;
      break;
    case CipherServiceErrorCode.dataPersistence:
      message = Strings.of(context).cipherDataPersistenceError;
      break;
    case CipherServiceErrorCode.invalidArgument:
      message = Strings.of(context).cipherInvalidArgumentError;
      break;
    case CipherServiceErrorCode.publicKeyError:
      message = Strings.of(context).cipherPublicKeyError;
      break;
    case CipherServiceErrorCode.secKeyNotFound:
      message = Strings.of(context).cipherSecKeyNotFoundError;
      break;
    case CipherServiceErrorCode.unknown:
      message = Strings.of(context).cipherUnknownError;
      break;
    case CipherServiceErrorCode.upgradeError:
      message = Strings.of(context).cipherUpgradeError;
      break;
    case CipherServiceErrorCode.unsupportedAlgorithm:
      message = Strings.of(context).cipherUnsupportedAlgorithmError;
      break;
  }

  PwDialog.showError(
    context,
    title: Strings.of(context).cipherErrorTitle,
    message: message,
  );
}

Future<void> _migrateSqlite(AccountStorageService accountStorageService,
    CipherService cipherService) async {
  final sqliteDb = await SqliteAccountStorageService.getDatabase();
  if (await sqliteDb.exists()) {
    _log.debug('Migrating sqlite db', tag: _tag);

    var success = true;
    final sqliteStorage = SqliteAccountStorageService();

    final accounts = await sqliteStorage.getAccounts();
    final selectedAccount = await sqliteStorage.getSelectedAccount();

    var migrated = 0;
    for (var account in accounts) {
      final privateKeys = <wallet.PrivateKey>[];

      final mainNetKeyId = '${account.id}-${ChainId.mainNet}';
      final testNetKeyId = '${account.id}-${ChainId.testNet}';

      final mainNetKey = await cipherService.decryptKey(
        id: mainNetKeyId,
      );
      final testNetKey = await cipherService.decryptKey(
        id: testNetKeyId,
      );

      if (mainNetKey != null) {
        privateKeys.add(wallet.PrivateKey.fromBip32(mainNetKey));
      }

      if (testNetKey != null) {
        privateKeys.add(wallet.PrivateKey.fromBip32(testNetKey));
      }

      if (privateKeys.length == 2) {
        final details = await accountStorageService.addAccount(
          name: account.name,
          privateKeys: privateKeys,
          selectedCoin: account.publicKey!.coin,
        );

        if (details != null) {
          if (account.id == selectedAccount?.id) {
            await accountStorageService.selectAccount(id: details.id);
          }

          await sqliteStorage.removeAccount(id: account.id);
          await cipherService.removeKey(id: mainNetKeyId);
          await cipherService.removeKey(id: testNetKeyId);
          migrated++;
        } else {
          success = false;
        }
      } else {
        success = false;
      }
    }

    if (success) {
      await sqliteStorage.close();
      await sqliteDb.delete();
    }

    _log.debug(
      'Migrate sqlite db success: $success, $migrated account(s)',
      tag: _tag,
    );
  }
}

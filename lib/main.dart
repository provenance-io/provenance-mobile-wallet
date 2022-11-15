import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:prov_wallet_flutter/prov_wallet_flutter.dart';
import 'package:provenance_dart/proto.dart';
import 'package:provenance_dart/wallet.dart' as wallet;
import 'package:provenance_dart/wallet_connect.dart';
import 'package:provenance_wallet/cipher_service_pw_error.dart';
import 'package:provenance_wallet/clients/multi_sig_client/multi_sig_client.dart';
import 'package:provenance_wallet/common/theme.dart';
import 'package:provenance_wallet/common/widgets/pw_dialog.dart';
import 'package:provenance_wallet/screens/start_screen.dart';
import 'package:provenance_wallet/services/account_notification_service/account_notification_service.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/account_service/account_storage_service.dart';
import 'package:provenance_wallet/services/account_service/account_storage_service_imp.dart';
import 'package:provenance_wallet/services/account_service/account_storage_service_kind.dart';
import 'package:provenance_wallet/services/account_service/default_transaction_handler.dart';
import 'package:provenance_wallet/services/account_service/sembast_account_storage_service_v2.dart';
import 'package:provenance_wallet/services/account_service/transaction_handler.dart';
import 'package:provenance_wallet/services/asset_client/asset_client.dart';
import 'package:provenance_wallet/services/asset_client/default_asset_client.dart';
import 'package:provenance_wallet/services/asset_client/mock_asset_client.dart';
import 'package:provenance_wallet/services/config_service/default_local_config_service.dart';
import 'package:provenance_wallet/services/config_service/default_remote_config_service.dart';
import 'package:provenance_wallet/services/config_service/firebase_remote_config_service.dart';
import 'package:provenance_wallet/services/config_service/local_config.dart';
import 'package:provenance_wallet/services/config_service/remote_config_service.dart';
import 'package:provenance_wallet/services/connectivity/connectivity_service.dart';
import 'package:provenance_wallet/services/connectivity/default_connectivity_service.dart';
import 'package:provenance_wallet/services/crash_reporting/crash_reporting_client.dart';
import 'package:provenance_wallet/services/crash_reporting/firebase_crash_reporting_client.dart';
import 'package:provenance_wallet/services/crash_reporting/logging_crash_reporting_client.dart';
import 'package:provenance_wallet/services/deep_link/deep_link_service.dart';
import 'package:provenance_wallet/services/deep_link/disabled_deep_link_service.dart';
import 'package:provenance_wallet/services/deep_link/firebase_deep_link_service.dart';
import 'package:provenance_wallet/services/gas_fee/default_gas_fee_client.dart';
import 'package:provenance_wallet/services/gas_fee/gas_fee_client.dart';
import 'package:provenance_wallet/services/governance/default_governance_client.dart';
import 'package:provenance_wallet/services/governance/governance_client.dart';
import 'package:provenance_wallet/services/http_client.dart';
import 'package:provenance_wallet/services/key_value_service/default_key_value_service.dart';
import 'package:provenance_wallet/services/key_value_service/key_value_service.dart';
import 'package:provenance_wallet/services/key_value_service/shared_preferences_key_value_store.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/services/multi_sig_service/multi_sig_service.dart';
import 'package:provenance_wallet/services/notification/basic_notification_service.dart';
import 'package:provenance_wallet/services/notification/notification_info.dart';
import 'package:provenance_wallet/services/notification/notification_kind.dart';
import 'package:provenance_wallet/services/notification/notification_service.dart';
import 'package:provenance_wallet/services/price_client/price_service.dart';
import 'package:provenance_wallet/services/remote_notification/default_remote_notification_service.dart';
import 'package:provenance_wallet/services/remote_notification/disabled_remote_notification_service.dart';
import 'package:provenance_wallet/services/remote_notification/multi_sig_topic.dart';
import 'package:provenance_wallet/services/remote_notification/remote_notification_service.dart';
import 'package:provenance_wallet/services/sqlite_account_storage_service.dart';
import 'package:provenance_wallet/services/stat_client/default_stat_client.dart';
import 'package:provenance_wallet/services/stat_client/stat_client.dart';
import 'package:provenance_wallet/services/transaction_client/default_transaction_client.dart';
import 'package:provenance_wallet/services/transaction_client/mock_transaction_client.dart';
import 'package:provenance_wallet/services/transaction_client/transaction_client.dart';
import 'package:provenance_wallet/services/tx_queue_service/default_tx_queue_service.dart';
import 'package:provenance_wallet/services/tx_queue_service/tx_queue_service.dart';
import 'package:provenance_wallet/services/validator_client/default_validator_client.dart';
import 'package:provenance_wallet/services/validator_client/mock_validator_client.dart';
import 'package:provenance_wallet/services/validator_client/validator_client.dart';
import 'package:provenance_wallet/services/wallet_connect_queue_service/wallet_connect_queue_service.dart';
import 'package:provenance_wallet/services/wallet_connect_service/default_wallet_connect_service.dart';
import 'package:provenance_wallet/services/wallet_connect_service/wallet_connect_service.dart';
import 'package:provenance_wallet/util/assets.dart';
import 'package:provenance_wallet/util/integration_test_data.dart';
import 'package:provenance_wallet/util/local_auth_helper.dart';
import 'package:provenance_wallet/util/localized_string.dart';
import 'package:provenance_wallet/util/logs/logging.dart';
import 'package:provenance_wallet/util/multi_sig_util.dart';
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

void main(List<String> args) {
  runApp(
    Phoenix(
      child: ProvenanceWalletApp(
        args: args,
      ),
    ),
  );
}

void _onDeepLink(Uri uri) {
  final uriStr = uri.toString();
  Log.instance.debug(
    'Deep link: $uriStr',
    tag: 'main',
  );

  switch (uri.path) {
    case '/invite':
      get<KeyValueService>().setString(
        PrefKey.multiSigInviteUri,
        uri.toString(),
      );
      break;
  }
}

Future<void> _integrationTestSetup(String json) async {
  final data = IntegrationTestData.fromJson(jsonDecode(json));
  if (data.switchAccountsTest != null) {
    final seedPhraseOne = data.recoveryPhrase!.split(" ");
    final seedPhraseTwo =
        data.switchAccountsTest!.recoveryPhraseTwo!.split(" ");
    final nameOne = data.accountName!;
    final nameTwo = data.switchAccountsTest!.nameTwo!;
    final pin = data.cipherPin!;

    final service = get<AccountService>();
    await service.addAccount(
      phrase: seedPhraseOne,
      name: nameOne,
      coin: wallet.Coin.testNet,
    );
    await service.addAccount(
      phrase: seedPhraseTwo,
      name: nameTwo,
      coin: wallet.Coin.testNet,
    );
    await get<CipherService>().setPin(pin);
  } else if (data.sendHashTest != null) {
    final seedPhraseOne = data.recoveryPhrase!.split(" ");

    final service = get<AccountService>();
    await service.addAccount(
      phrase: seedPhraseOne,
      name: data.accountName!,
      coin: wallet.Coin.testNet,
    );
    await get<CipherService>().setPin(data.cipherPin!);
  }
}

class ProvenanceWalletApp extends StatefulWidget {
  const ProvenanceWalletApp({
    Key? key,
    required this.args,
  }) : super(key: key);

  final List<String> args;

  @override
  State<StatefulWidget> createState() => _ProvenanceWalletAppState();
}

class _ProvenanceWalletAppState extends State<ProvenanceWalletApp> {
  bool _isSetupComplete = false;
  bool _setupAlreadyRun = false;

  final _subscriptions = CompositeSubscription();
  final _navigatorKey = GlobalKey<NavigatorState>();
  var _authStatus = AuthStatus.noAccount;

  @override
  Future<void> didChangeDependencies() async {
    if (_setupAlreadyRun) {
      super.didChangeDependencies();
      return;
    }
    _setupAlreadyRun = true;
    await _setup();
    setState(() {
      _isSetupComplete = true;
    });
    super.didChangeDependencies();
  }

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
      home: Stack(
        children: [
          if (!_isSetupComplete)
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(Assets.imagePaths.background),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          if (_isSetupComplete) StartScreen(),
          if (!_isSetupComplete)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
      navigatorKey: _navigatorKey,
    );
  }

  Future<void> _setup() async {
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails errorDetails) {
      originalOnError?.call(errorDetails);
      if (get.isRegistered<CrashReportingClient>()) {
        get<CrashReportingClient>().recordFlutterError(errorDetails);
      }
    };

    if (_enableFirebase) {
      DefaultRemoteNotificationService.onBackgroundMultiSigNotification(
          (message) async {
        final title = message.title;
        if (title != null) {
          await AccountNotificationService.addInBackground(
            label: title,
            created: DateTime.now(),
          );
        }
      });
    }
    await runZonedGuarded(
      () async {
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

        CrashReportingClient crashReportingService;
        RemoteNotificationService remoteNotificationService;
        RemoteConfigService remoteConfigService;
        DeepLinkService deepLinkService;

        _log.info('Enable Firebase: $_enableFirebase', tag: _tag);

        if (_enableFirebase && !Platform.isMacOS) {
          await Firebase.initializeApp();

          crashReportingService = FirebaseCrashReportingClient();

          remoteNotificationService = DefaultRemoteNotificationService();

          remoteConfigService = FirebaseRemoteConfigService(
            keyValueService: keyValueService,
            localConfigService: localConfigService,
          );

          final firebaseDeepLinkService = FirebaseDeepLinkService();
          firebaseDeepLinkService.link.listen(_onDeepLink);
          firebaseDeepLinkService.init();
          deepLinkService = firebaseDeepLinkService;
        } else {
          crashReportingService = LoggingCrashReportingClient();
          remoteNotificationService = DisabledRemoteNotificationService();
          remoteConfigService = DefaultRemoteConfigService(
            localConfigService: localConfigService,
          );
          deepLinkService = DisabledDeepLinkService();
        }

        get.registerSingleton<CrashReportingClient>(
          crashReportingService,
        );

        final allowCrashReporting = _testingCrashReporting ||
            ((await keyValueService.getBool(PrefKey.allowCrashlitics) ??
                    true) &&
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

        const accountDbFilename = 'account.db';

        AccountStorageService accountStorageService;

        switch (AccountStorageServiceKind.values.byName(_accountServiceKind)) {
          case AccountStorageServiceKind.sembast:
            final directory = await getApplicationDocumentsDirectory();
            await directory.create(recursive: true);
            final serviceCore = SembastAccountStorageServiceV2(
              factory: databaseFactoryIo,
              dbPath: path.join(directory.absolute.path, accountDbFilename),
            );
            accountStorageService =
                AccountStorageServiceImp(serviceCore, cipherService);

            await _migrateSqlite(accountStorageService, cipherService);

            break;
          case AccountStorageServiceKind.memory:
            final serviceCore = SembastAccountStorageServiceV2(
              factory: databaseFactoryMemory,
              dbPath: path.join(sembastInMemoryDatabasePath, accountDbFilename),
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

        final multiSigClient = MultiSigClient();
        get.registerSingleton<MultiSigClient>(multiSigClient);

        final accountService = AccountService(
          storage: accountStorageService,
        );
        get.registerSingleton<AccountService>(accountService);

        final multiSigService = MultiSigService(
          accountService: accountService,
          multiSigClient: multiSigClient,
        );
        get.registerSingleton<MultiSigService>(multiSigService);

        get.registerSingleton<LocalAuthHelper>(LocalAuthHelper());

        final directory = await getApplicationDocumentsDirectory();
        await directory.create(recursive: true);

        get.registerSingleton<WalletConnectQueueService>(
          WalletConnectQueueService(
            factory: databaseFactoryIo,
            directory: directory.absolute.path,
          ),
        );

        final json = widget.args.firstOrNull;

        if (json != null) {
          await _integrationTestSetup(json);
        }
        return;
      },
      (error, stack) {
        if (get.isRegistered<CrashReportingClient>()) {
          get<CrashReportingClient>().recordError(
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

    final keyValueService = get<KeyValueService>();
    final cipherService = get<CipherService>();

    cipherService.error.listen((e) {
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
          coin.chainId,
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

    get.registerLazySingleton<StatClient>(
      () => DefaultStatClient(),
    );
    final isMockingAssetService =
        await keyValueService.getBool(PrefKey.isMockingAssetService) ?? false;

    get.registerLazySingleton<AssetClient>(
      () => isMockingAssetService ? MockAssetClient() : DefaultAssetClient(),
    );

    final isMockingTransactionService =
        await keyValueService.getBool(PrefKey.isMockingTransactionService) ??
            false;

    get.registerLazySingleton<TransactionClient>(
      () => isMockingTransactionService
          ? MockTransactionClient()
          : DefaultTransactionClient(),
    );

    final isMockingValidatorService =
        await keyValueService.getBool(PrefKey.isMockingValidatorService) ??
            false;

    get.registerLazySingleton<ValidatorClient>(
      () => isMockingValidatorService
          ? MockValidatorClient()
          : DefaultValidatorClient(),
    );

    // final isMockingGovernanceService =
    //     await keyValueService.getBool(PrefKey.isMockingGovernanceService) ??
    //         false;
    get.registerLazySingleton<GovernanceClient>(
      () => //isMockingGovernanceService
          //? MockGovernanceService() :
          DefaultGovernanceClient(),
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
    get.registerLazySingleton<GasFeeClient>(
      () => DefaultGasFeeClient(),
    );

    WalletConnection walletConnectionFactory(address) =>
        WalletConnection(address);
    get.registerSingleton<WalletConnectionFactory>(walletConnectionFactory);
    final transactionHandler = DefaultTransactionHandler();
    get.registerSingleton<TransactionHandler>(
      transactionHandler,
    );

    get.registerLazySingleton<PriceClient>(
      () => PriceClient(),
    );

    final accountService = get<AccountService>();
    final multiSigService = get<MultiSigService>();

    final txQueueService = DefaultQueueTxService(
      transactionHandler: transactionHandler,
      multiSigService: multiSigService,
      accountService: accountService,
    );
    get.registerSingleton<TxQueueService>(txQueueService);

    final remoteNotificationService = get<RemoteNotificationService>();
    final walletConnectQueueService = get<WalletConnectQueueService>();

    get.registerSingleton<WalletConnectService>(
      DefaultWalletConnectService(
        keyValueService: keyValueService,
        accountService: accountService,
        txQueueService: txQueueService,
        connectionFactory: walletConnectionFactory,
        notificationService: remoteNotificationService,
        queueService: walletConnectQueueService,
        localAuthHelper: authHelper,
      ),
    );

    final accountNotificationService = AccountNotificationService();
    get.registerSingleton<AccountNotificationService>(
        accountNotificationService);

    multiSigService.txCreated.listen((event) {
      accountNotificationService.addId(
        id: StringId.multiSigTransactionInitiatedNotification,
        created: DateTime.now(),
      );
    }).addTo(_subscriptions);

    remoteNotificationService.multiSig.listen((e) {
      final title = e.title;
      if (title != null) {
        accountNotificationService.addText(
          label: title,
          created: DateTime.now(),
        );
      }
    }).addTo(_subscriptions);

    final accounts = await accountService.getAccounts();
    for (var account in accounts) {
      final address = account.address;
      if (address != null) {
        await remoteNotificationService.registerForPushNotifications(address);
      }
    }

    accountService.events.added.listen((e) {
      final address = e.address;
      if (address != null) {
        remoteNotificationService.registerForPushNotifications(address).onError(
              (error, stackTrace) => logDebug(
                'Add event failed to register for push notifications for account: $address',
              ),
            );
      }
    }).addTo(_subscriptions);

    accountService.events.removed.listen((e) async {
      for (var account in e) {
        final address = account.address;
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

      final accounts = await accountService.getAccounts();
      if (accounts.isEmpty) {
        authHelper.reset();
      }
    }).addTo(_subscriptions);

    accountService.events.updated.listen((e) {
      final address = e.address;
      if (address != null && !remoteNotificationService.isRegistered(address)) {
        remoteNotificationService.registerForPushNotifications(address).onError(
              (error, stackTrace) => logDebug(
                'Update event failed to register for push notifications for account: $address',
              ),
            );
      }
    }).addTo(_subscriptions);

    remoteNotificationService.multiSig.listen((e) async {
      final data = e.data;
      final address = data.address;
      if (address == null) {
        return;
      }

      switch (data.topic) {
        case MultiSigTopic.accountComplete:
          _activatePendingMultiAccounts();
          break;
        case MultiSigTopic.txSignatureRequired:
        case MultiSigTopic.txReady:
        case MultiSigTopic.txDeclined:
        case MultiSigTopic.txResult:
          final accounts = await accountService.getTransactableAccounts();
          final account =
              accounts.firstWhereOrNull((e) => e.address == address);
          if (account != null) {
            await multiSigService.sync(
              signers: [
                SignerData(
                  address: address,
                  coin: account.coin,
                ),
              ],
            );
          }

          break;
      }
    });

    if (accounts.isNotEmpty) {
      // Don't delay startup by awaiting here
      multiSigService.sync(
          signers: accounts
              .whereType<TransactableAccount>()
              .map((e) => SignerData(
                    address: e.address,
                    coin: e.coin,
                  ))
              .toList());

      await _activatePendingMultiAccounts();
    }
  }

  Future<void> _activatePendingMultiAccounts() async {
    final accountService = get<AccountService>();

    final accounts = await accountService.getAccounts();
    final pendingAccounts = accounts
        .whereType<MultiAccount>()
        .where((e) => e.address == null)
        .toList();

    for (var pendingAccount in pendingAccounts) {
      final activated = await tryActivateAccount(pendingAccount);
      if (activated) {
        logDebug(
            'Activated multi sig account: ${pendingAccount.name}, linked to: ${pendingAccount.linkedAccount.name}');
      }
    }
  }
}

void showCipherServiceError(BuildContext context, CipherServiceError error) {
  PwDialog.showError(
    context: context,
    error: CipherServicePwError(
      inner: error,
    ),
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
      wallet.PrivateKey? privateKey;

      final mainNetKeyId = '${account.id}-${wallet.Coin.mainNet.chainId}';
      final testNetKeyId = '${account.id}-${wallet.Coin.testNet.chainId}';

      final mainNetKey = await cipherService.decryptKey(
        id: mainNetKeyId,
      );

      if (mainNetKey != null) {
        privateKey = wallet.PrivateKey.fromBip32(mainNetKey);
      }

      if (privateKey != null) {
        final details = await accountStorageService.addAccount(
          name: account.name,
          privateKey: privateKey,
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

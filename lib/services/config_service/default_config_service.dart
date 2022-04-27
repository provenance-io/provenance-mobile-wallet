import 'dart:async';
import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart'
    show FirebaseRemoteConfig, RemoteConfigSettings;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provenance_wallet/services/config_service/config_service.dart';
import 'package:provenance_wallet/services/config_service/endpoints.dart';
import 'package:provenance_wallet/services/config_service/flavor.dart';
import 'package:provenance_wallet/services/config_service/local_config.dart';
import 'package:provenance_wallet/services/config_service/remote_config.dart';
import 'package:provenance_wallet/services/config_service/remote_config_key.dart';
import 'package:provenance_wallet/services/key_value_service/key_value_service.dart';
import 'package:provenance_wallet/util/lazy.dart';
import 'package:provenance_wallet/util/logs/logging.dart';

class DefaultConfigService implements ConfigService {
  DefaultConfigService({
    required KeyValueService keyValueService,
    required FirebaseRemoteConfig firebaseRemoteConfig,
  })  : _keyValueService = keyValueService,
        _firebaseRemoteConfig = firebaseRemoteConfig {
    _lazyLocalConfig = Lazy(_getLocalConfig);
    _lazyRemoteConfig = Lazy(_getRemoteConfig);
  }

  // Max time for a remote config fetch
  static const _remoteFetchTimeout = Duration(minutes: 1);
  // Minimum duration between remote config fetches
  static const _remoteMinFetchInterval = Duration(seconds: 10);

  final KeyValueService _keyValueService;
  final FirebaseRemoteConfig _firebaseRemoteConfig;

  late final Lazy<Future<LocalConfig>> _lazyLocalConfig;
  late final Lazy<Future<RemoteConfig>> _lazyRemoteConfig;

  @override
  Future<LocalConfig> getLocalConfig() => _lazyLocalConfig.value;

  @override
  Future<RemoteConfig> getRemoteConfig() => _lazyRemoteConfig.value;

  Future<LocalConfig> _getLocalConfig() async {
    final info = await PackageInfo.fromPlatform();

    final flavor = _getFlavor(info.packageName);

    final config = LocalConfig(
      packageId: info.packageName,
      version: info.version,
      buildNumber: info.buildNumber,
      flavor: flavor,
    );

    return config;
  }

  Future<RemoteConfig> _getRemoteConfig() async {
    final localConfig = await getLocalConfig();
    final flavor = localConfig.flavor;

    await _firebaseRemoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: _remoteFetchTimeout,
        minimumFetchInterval: _remoteMinFetchInterval,
      ),
    );

    // Call fetch() and activate() separately. Calling fetchAndActivate()
    // seems to return true every time regardless of whether the remote
    // config was actually updated.
    try {
      await _firebaseRemoteConfig.fetch();
    } on Exception catch (e) {
      logDebug('Failed to fetch remote config: $e');
    }

    final didActivate = await _firebaseRemoteConfig.activate();
    if (didActivate) {
      logDebug('Activated new remote config');

      final remoteConfigKey = _getRemoteConfigKey(flavor);
      final endpointsJson =
          _firebaseRemoteConfig.getString(remoteConfigKey.name);
      if (endpointsJson.isNotEmpty) {
        try {
          // Verify json deserialization
          final _ = Endpoints.fromJson(jsonDecode(endpointsJson));

          await _keyValueService.setString(PrefKey.endpoints, endpointsJson);
        } on Error catch (e) {
          logError('Failed to save endpoints', error: e);
        } on Exception catch (e) {
          logError('Failed to save endpoints', error: e);
        }
      }
    }

    var endpoints = Endpoints.forFlavor(flavor);

    final endpointsJson = await _keyValueService.getString(PrefKey.endpoints);
    if (endpointsJson != null) {
      try {
        final endpointsOverride = Endpoints.fromJson(jsonDecode(endpointsJson));
        if (endpointsOverride.version > endpoints.version) {
          endpoints = endpointsOverride;
        }
      } on Error catch (e) {
        logError('Failed to parse remote endpoints.', error: e);
      } on Exception catch (e) {
        logError('Failed to parse remote endpoints.', error: e);
      }
    }

    final remoteConfig = RemoteConfig(
      endpoints: endpoints,
    );

    logDebug('Initializing: $remoteConfig');

    return remoteConfig;
  }

  Flavor _getFlavor(String packageId) {
    switch (packageId) {
      case 'io.provenance.wallet':
        return Flavor.prod;
      case 'io.provenance.wallet.dev':
        return Flavor.dev;
      default:
        throw 'Unknown packageId: $packageId';
    }
  }

  RemoteConfigKey _getRemoteConfigKey(Flavor flavor) {
    switch (flavor) {
      case Flavor.prod:
        return RemoteConfigKey.endpointsProd;
      case Flavor.dev:
        return RemoteConfigKey.endpointsDev;
    }
  }
}

import 'dart:async';
import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart'
    show FirebaseRemoteConfig, RemoteConfigSettings;
import 'package:provenance_wallet/services/config_service/endpoints.dart';
import 'package:provenance_wallet/services/config_service/flavor.dart';
import 'package:provenance_wallet/services/config_service/local_config_service.dart';
import 'package:provenance_wallet/services/config_service/remote_config.dart';
import 'package:provenance_wallet/services/config_service/remote_config_key.dart';
import 'package:provenance_wallet/services/config_service/remote_config_service.dart';
import 'package:provenance_wallet/services/key_value_service/key_value_service.dart';
import 'package:provenance_wallet/util/lazy.dart';
import 'package:provenance_wallet/util/logs/logging.dart';

class FirebaseRemoteConfigService implements RemoteConfigService {
  FirebaseRemoteConfigService({
    required KeyValueService keyValueService,
    required LocalConfigService localConfigService,
  })  : _keyValueService = keyValueService,
        _localConfigService = localConfigService {
    _lazyRemoteConfig = Lazy(_getRemoteConfig);
  }

  // Max time for a remote config fetch
  static const _remoteFetchTimeout = Duration(minutes: 1);
  // Minimum duration between remote config fetches
  static const _remoteMinFetchInterval = Duration(seconds: 10);

  final KeyValueService _keyValueService;
  final LocalConfigService _localConfigService;
  final FirebaseRemoteConfig _firebaseRemoteConfig =
      FirebaseRemoteConfig.instance;

  late final Lazy<Future<RemoteConfig>> _lazyRemoteConfig;

  @override
  Future<RemoteConfig> getRemoteConfig() => _lazyRemoteConfig.value;

  Future<RemoteConfig> _getRemoteConfig() async {
    final localConfig = await _localConfigService.getConfig();
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

  RemoteConfigKey _getRemoteConfigKey(Flavor flavor) {
    switch (flavor) {
      case Flavor.prod:
        return RemoteConfigKey.endpointsProd;
      case Flavor.dev:
        return RemoteConfigKey.endpointsDev;
    }
  }
}

import 'package:provenance_wallet/services/config_service/endpoints.dart';
import 'package:provenance_wallet/services/config_service/local_config_service.dart';
import 'package:provenance_wallet/services/config_service/remote_config.dart';
import 'package:provenance_wallet/services/config_service/remote_config_service.dart';

class DefaultRemoteConfigService implements RemoteConfigService {
  DefaultRemoteConfigService({
    required LocalConfigService localConfigService,
  }) : _localConfigService = localConfigService;

  final LocalConfigService _localConfigService;

  @override
  Future<RemoteConfig> getRemoteConfig() async {
    final localConfig = await _localConfigService.getConfig();

    final endpoints = Endpoints.forFlavor(localConfig.flavor);

    return RemoteConfig(
      endpoints: endpoints,
    );
  }
}

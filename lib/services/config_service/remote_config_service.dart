import 'package:provenance_wallet/services/config_service/remote_config.dart';

abstract class RemoteConfigService {
  Future<RemoteConfig> getRemoteConfig();
}

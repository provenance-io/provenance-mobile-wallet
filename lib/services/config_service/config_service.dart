import 'package:provenance_wallet/services/config_service/local_config.dart';
import 'package:provenance_wallet/services/config_service/remote_config.dart';

abstract class ConfigService {
  Future<LocalConfig> getLocalConfig();
  Future<RemoteConfig> getRemoteConfig();
}

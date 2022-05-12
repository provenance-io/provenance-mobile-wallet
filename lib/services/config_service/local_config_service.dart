import 'package:provenance_wallet/services/config_service/local_config.dart';

abstract class LocalConfigService {
  Future<LocalConfig> getConfig();
}

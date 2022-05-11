import 'package:package_info_plus/package_info_plus.dart';
import 'package:provenance_wallet/services/config_service/flavor.dart';
import 'package:provenance_wallet/services/config_service/local_config.dart';
import 'package:provenance_wallet/services/config_service/local_config_service.dart';
import 'package:provenance_wallet/util/lazy.dart';

class DefaultLocalConfigService implements LocalConfigService {
  DefaultLocalConfigService() {
    _lazyLocalConfig = Lazy(_getLocalConfig);
  }

  late final Lazy<Future<LocalConfig>> _lazyLocalConfig;

  @override
  Future<LocalConfig> getConfig() => _lazyLocalConfig.value;

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

  Flavor _getFlavor(String packageId) {
    switch (packageId) {
      case 'io.provenance.wallet':
        return Flavor.prod;
      case 'io.provenance.wallet.dev':
        return Flavor.dev;
      case 'provenance_wallet':
        return Flavor.web;
      default:
        throw 'Unknown packageId: $packageId';
    }
  }
}

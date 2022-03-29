import 'package:firebase_core/firebase_core.dart';
import 'package:provenance_wallet/config/firebase_dev_options.dart';
import 'package:provenance_wallet/config/firebase_prod_options.dart';
import 'package:provenance_wallet/config/flavor.dart';

class Config {
  Config.dev()
      : flavor = Flavor.dev,
        firebaseOptions = FirebaseDevOptions.currentPlatform;

  Config.prod()
      : flavor = Flavor.prod,
        firebaseOptions = FirebaseProdOptions.currentPlatform;

  factory Config.fromPackageName(String name) {
    Config config;
    switch (name) {
      case 'io.provenance.wallet':
        config = Config.prod();
        break;
      case 'io.provenance.wallet.dev':
        config = Config.dev();
        break;
      default:
        throw 'Invalid package name: $name';
    }

    return config;
  }

  final Flavor flavor;
  final FirebaseOptions firebaseOptions;
}

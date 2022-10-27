import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:prov_wallet_flutter/prov_wallet_flutter.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/util/get.dart';

import './create_account_test.dart' as t1;
import './recover_account_test.dart' as t2;
import './send_hash_test.dart' as t3;
import './switch_accounts_test.dart' as t4;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized().framePolicy =
      LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  tearDown(() async {
    get<AccountService>().resetAccounts();
    get<CipherService>().deletePin();
    await get.reset();
  });

  group("Create Account Test", () {
    t1.main();
  });
  group("Recover Account Test", () {
    t2.main();
  });
  group("Send Hash Test", () {
    t3.main();
  });
  group("Switch Accounts Test", () {
    t4.main();
  });
}

import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/dashboard/profile/category_label.dart';
import 'package:provenance_wallet/screens/dashboard/profile/toggle_item.dart';
import 'package:provenance_wallet/screens/landing/landing_screen.dart';
import 'package:provenance_wallet/services/asset_service/asset_service.dart';
import 'package:provenance_wallet/services/asset_service/default_asset_service.dart';
import 'package:provenance_wallet/services/asset_service/mock_asset_service.dart';
import 'package:provenance_wallet/services/key_value_service.dart';
import 'package:provenance_wallet/services/transaction_service/default_transaction_service.dart';
import 'package:provenance_wallet/services/transaction_service/mock_transaction_service.dart';
import 'package:provenance_wallet/services/transaction_service/transaction_service.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class ServiceMocksScreen extends StatefulWidget {
  const ServiceMocksScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ServiceMocksScreenState();
}

class ServiceMocksScreenState extends State<ServiceMocksScreen> {
  var _didChange = false;

  @override
  Widget build(BuildContext context) {
    final keyValueService = get<KeyValueService>();
    final mockingAssetStream =
        keyValueService.streamBool(PrefKey.isMockingAssetService);
    final mockingTransactionsStream =
        keyValueService.streamBool(PrefKey.isMockingTransactionService);

    return Container(
      color: Theme.of(context).colorScheme.neutral750,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          textDirection: TextDirection.ltr,
          children: [
            PwAppBar(
              title: Strings.profileDeveloperServiceMocks,
              leadingIconOnPress: () {
                if (_didChange) {
                  var navigator = Navigator.of(context);
                  navigator.popUntil((route) => route.isFirst);
                  navigator.pop();
                  navigator.push(LandingScreen().route());
                }
              },
            ),
            CategoryLabel(Strings.profileDeveloperServiceMocks),
            PwListDivider(),
            StreamBuilder<bool?>(
              initialData: mockingAssetStream.value,
              stream: mockingAssetStream,
              builder: (context, snapshot) {
                final data = snapshot.data ?? false;

                return ToggleItem(
                  text: Strings.developerMocksMockAssetService,
                  value: data,
                  onChanged: (value) async {
                    _didChange = true;
                    await keyValueService.setBool(
                      PrefKey.isMockingAssetService,
                      !data,
                    );
                    get.unregister<AssetService>();
                    if (value) {
                      get.registerSingleton<AssetService>(
                        MockAssetService(),
                      );
                    } else {
                      get.registerSingleton<AssetService>(
                        DefaultAssetService(),
                      );
                    }
                  },
                );
              },
            ),
            PwListDivider(),
            StreamBuilder<bool?>(
              initialData: mockingTransactionsStream.value,
              stream: mockingTransactionsStream,
              builder: (context, snapshot) {
                final data = snapshot.data ?? false;

                return ToggleItem(
                  text: Strings.developerMocksMockTransactionService,
                  value: data,
                  onChanged: (value) async {
                    _didChange = true;
                    await keyValueService.setBool(
                      PrefKey.isMockingTransactionService,
                      !data,
                    );
                    get.unregister<TransactionService>();
                    if (value) {
                      get.registerSingleton<TransactionService>(
                        MockTransactionService(),
                      );
                    } else {
                      get.registerSingleton<TransactionService>(
                        DefaultTransactionService(),
                      );
                    }
                  },
                );
              },
            ),
            PwListDivider(),
          ],
        ),
      ),
    );
  }
}

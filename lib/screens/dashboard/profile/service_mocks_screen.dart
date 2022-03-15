import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/dashboard/profile/category_label.dart';
import 'package:provenance_wallet/screens/dashboard/profile/toggle_item.dart';
import 'package:provenance_wallet/services/key_value_service.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class ServiceMocksScreen extends StatelessWidget {
  const ServiceMocksScreen({Key? key}) : super(key: key);

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
                    await keyValueService.setBool(
                      PrefKey.isMockingAssetService,
                      !data,
                    );
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
                    await keyValueService.setBool(
                      PrefKey.isMockingTransactionService,
                      !data,
                    );
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

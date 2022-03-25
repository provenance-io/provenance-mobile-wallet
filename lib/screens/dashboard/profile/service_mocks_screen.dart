import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/common/widgets/pw_dialog.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/dashboard/profile/category_label.dart';
import 'package:provenance_wallet/screens/dashboard/profile/toggle_item.dart';
import 'package:provenance_wallet/services/key_value_service.dart';
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
              leadingIconOnPress: () async {
                if (_didChange) {
                  var shouldRestart = await PwDialog.showConfirmation(
                    context,
                    title: Strings.developerMocksServiceUpdate,
                    message: Strings.developerMocksRestartTheAppMessage,
                    confirmText: Strings.developerMocksRestart,
                    cancelText: Strings.cancel,
                  );
                  if (shouldRestart) {
                    try {
                      await get.popScope();
                      get.pushNewScope();
                      Phoenix.rebirth(context);
                    } catch (e) {
                      // Already in base scope, can't pop it.
                      get.pushNewScope();
                      Phoenix.rebirth(context);
                    }
                  } else {
                    Navigator.of(context).pop();
                  }
                } else {
                  Navigator.of(context).pop();
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

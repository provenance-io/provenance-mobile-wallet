import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/common/widgets/pw_dialog.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/home/settings/category_label.dart';
import 'package:provenance_wallet/screens/home/settings/toggle_item.dart';
import 'package:provenance_wallet/services/key_value_service/key_value_service.dart';
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
    final strings = Strings.of(context);
    final keyValueService = get<KeyValueService>();
    final mockingAssetStream =
        keyValueService.stream<bool>(PrefKey.isMockingAssetService);
    final mockingTransactionsStream =
        keyValueService.stream<bool>(PrefKey.isMockingTransactionService);

    return Container(
      color: Theme.of(context).colorScheme.neutral750,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          textDirection: TextDirection.ltr,
          children: [
            PwAppBar(
              title: strings.profileDeveloperServiceMocks,
              leadingIconOnPress: () async {
                if (_didChange) {
                  var shouldRestart = await PwDialog.showConfirmation(
                    context,
                    title: strings.developerMocksServiceUpdate,
                    message: strings.developerMocksRestartTheAppMessage,
                    confirmText: strings.developerMocksRestart,
                    cancelText: strings.cancel,
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
            CategoryLabel(strings.profileDeveloperServiceMocks),
            PwListDivider(),
            StreamBuilder<KeyValueData<bool>>(
              initialData: mockingAssetStream.valueOrNull,
              stream: mockingAssetStream,
              builder: (context, snapshot) {
                if (snapshot.data == null) {
                  return Container();
                }

                final data = snapshot.data?.data ?? false;

                return ToggleItem(
                  text: strings.developerMocksMockAssetService,
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
            StreamBuilder<KeyValueData<bool>>(
              initialData: mockingTransactionsStream.valueOrNull,
              stream: mockingTransactionsStream,
              builder: (context, snapshot) {
                if (snapshot.data == null) {
                  return Container();
                }

                final data = snapshot.data?.data ?? false;

                return ToggleItem(
                  text: strings.developerMocksMockTransactionService,
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

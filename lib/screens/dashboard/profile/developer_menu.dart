import 'package:provenance_blockchain_wallet/common/pw_design.dart';
import 'package:provenance_blockchain_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_blockchain_wallet/screens/dashboard/dashboard_bloc.dart';
import 'package:provenance_blockchain_wallet/screens/dashboard/profile/category_label.dart';
import 'package:provenance_blockchain_wallet/screens/dashboard/profile/link_item.dart';
import 'package:provenance_blockchain_wallet/screens/dashboard/profile/service_mocks_screen.dart';
import 'package:provenance_blockchain_wallet/screens/dashboard/profile/toggle_item.dart';
import 'package:provenance_blockchain_wallet/screens/dashboard/profile/wallet_connect_item.dart';
import 'package:provenance_blockchain_wallet/services/key_value_service/key_value_service.dart';
import 'package:provenance_blockchain_wallet/util/get.dart';
import 'package:provenance_blockchain_wallet/util/strings.dart';

class DeveloperMenu extends StatelessWidget {
  const DeveloperMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final keyValueService = get<KeyValueService>();
    final diagnostics500Stream =
        keyValueService.stream<bool>(PrefKey.httpClientDiagnostics500);

    return Column(
      textDirection: TextDirection.ltr,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CategoryLabel(Strings.profileDeveloperCategoryTitle),
        PwListDivider(),
        WalletConnectItem(),
        PwListDivider(),
        StreamBuilder<KeyValueData<bool>>(
          initialData: diagnostics500Stream.valueOrNull,
          stream: diagnostics500Stream,
          builder: (context, snapshot) {
            if (snapshot.data == null) {
              return Container();
            }

            final data = snapshot.data?.data ?? false;

            return ToggleItem(
              text: Strings.profileDeveloperHttpClients500,
              value: data,
              onChanged: (value) async {
                await keyValueService.setBool(
                  PrefKey.httpClientDiagnostics500,
                  !data,
                );
                get<DashboardBloc>().load();
              },
            );
          },
        ),
        PwListDivider(),
        LinkItem(
          text: Strings.profileDeveloperServiceMocks,
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => ServiceMocksScreen(),
            );
          },
        ),
      ],
    );
  }
}

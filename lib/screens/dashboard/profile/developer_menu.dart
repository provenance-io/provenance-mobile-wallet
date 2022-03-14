import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/dashboard/dashboard_bloc.dart';
import 'package:provenance_wallet/screens/dashboard/profile/category_label.dart';
import 'package:provenance_wallet/screens/dashboard/profile/toggle_item.dart';
import 'package:provenance_wallet/services/key_value_service.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class DeveloperMenu extends StatelessWidget {
  const DeveloperMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final keyValueService = get<KeyValueService>();
    final diagnostics500Stream =
        keyValueService.streamBool(PrefKey.httpClientDiagnostics500);

    return Column(
      textDirection: TextDirection.ltr,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CategoryLabel(Strings.profileDeveloperCategoryTitle),
        PwListDivider(),
        StreamBuilder<bool?>(
          initialData: diagnostics500Stream.value,
          stream: diagnostics500Stream,
          builder: (context, snapshot) {
            final data = snapshot.data ?? false;

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
      ],
    );
  }
}

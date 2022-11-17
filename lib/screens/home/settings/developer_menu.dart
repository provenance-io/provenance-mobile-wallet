import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/home/settings/category_label.dart';
import 'package:provenance_wallet/screens/home/settings/link_item.dart';
import 'package:provenance_wallet/screens/home/settings/service_mocks_screen.dart';
import 'package:provenance_wallet/screens/home/settings/toggle_item.dart';
import 'package:provenance_wallet/screens/home/settings/wallet_connect_item.dart';
import 'package:provenance_wallet/services/key_value_service/key_value_service.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class DeveloperMenu extends StatelessWidget {
  const DeveloperMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final strings = Strings.of(context);
    final keyValueService = get<KeyValueService>();
    final diagnostics500Stream =
        keyValueService.stream<bool>(PrefKey.httpClientDiagnostics500);

    return Column(
      textDirection: TextDirection.ltr,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CategoryLabel(strings.profileDeveloperCategoryTitle),
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
              text: strings.profileDeveloperHttpClients500,
              value: data,
              onChanged: (value) async {
                await keyValueService.setBool(
                  PrefKey.httpClientDiagnostics500,
                  !data,
                );
              },
            );
          },
        ),
        PwListDivider(),
        StreamBuilder<KeyValueData<bool>>(
          initialData: keyValueService
              .stream<bool>(PrefKey.allowProposalCreation)
              .valueOrNull,
          stream: keyValueService.stream<bool>(PrefKey.allowProposalCreation),
          builder: (context, snapshot) {
            if (snapshot.data == null) {
              return Container();
            }

            final shouldAllowProposalCreation = snapshot.data?.data ?? false;

            return ToggleItem(
              text: strings.developerMenuAllowProposalCreation,
              value: shouldAllowProposalCreation,
              onChanged: (value) async {
                await keyValueService.setBool(
                  PrefKey.allowProposalCreation,
                  !shouldAllowProposalCreation,
                );
                if (!shouldAllowProposalCreation) {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) {
                      final theme = Theme.of(context);
                      return AlertDialog(
                        backgroundColor:
                            Theme.of(context).colorScheme.neutral750,
                        title: Text(
                          strings.stakingDelegateBeforeYouContinue,
                          style: theme.textTheme.footnote,
                          textAlign: TextAlign.center,
                        ),
                        content: Text(
                          strings.developerMenuProposalCreationTestnet,
                          style: theme.textTheme.body,
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: PwText(
                              strings.okay,
                              style: PwTextStyle.bodyBold,
                            ),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            );
          },
        ),
        PwListDivider(),
        LinkItem(
          text: strings.profileDeveloperServiceMocks,
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

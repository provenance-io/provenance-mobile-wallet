import 'package:provenance_wallet/clients/multi_sig_client/models/multi_sig_remote_account.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/screens/home/accounts/account_item.dart';
import 'package:provenance_wallet/services/models/account.dart';

class MultiSigRemoteAccountItem extends StatelessWidget {
  const MultiSigRemoteAccountItem({
    required this.account,
    required this.linkedAccount,
    required this.isActive,
    Key? key,
  }) : super(key: key);

  final MultiSigRemoteAccount account;
  final BasicAccount linkedAccount;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AccountContainer(
          name: account.name,
          rows: [
            AccountTitleRow(
              name: account.name,
              kind: AccountKind.multi,
              isSelected: isActive,
            ),
          ],
          isSelected: isActive,
        ),
        Divider(
            height: 1,
            thickness: 1,
            endIndent: Spacing.xLarge,
            indent: Spacing.xLarge,
            color: Theme.of(context).colorScheme.neutral750),
        LinkedAccount(
          name: linkedAccount.name,
          isSelected: isActive,
        ),
      ],
    );
  }
}

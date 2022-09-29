import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/extension/coin_extension.dart';
import 'package:provenance_wallet/screens/home/accounts/accounts_bloc.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:provider/provider.dart';

class AccountTitleRow extends StatelessWidget {
  const AccountTitleRow({
    required this.name,
    required this.kind,
    required this.isSelected,
    Key? key,
  }) : super(key: key);

  final String name;
  final AccountKind kind;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: Spacing.large,
      runSpacing: Spacing.small,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        PwText(
          name,
          style: PwTextStyle.bodyBold,
          overflow: TextOverflow.fade,
          color: PwColor.neutralNeutral,
          softWrap: true,
        ),
        Chip(
          label: PwText(
            _accountKindName(context, kind),
            style: PwTextStyle.footnote,
            color: isSelected ? PwColor.secondary350 : PwColor.neutral250,
          ),
          backgroundColor: isSelected
              ? Theme.of(context).colorScheme.secondary700
              : Theme.of(context).colorScheme.neutral600,
        ),
      ],
    );
  }

  String _accountKindName(BuildContext context, AccountKind kind) {
    String name;

    switch (kind) {
      case AccountKind.basic:
        name = Strings.of(context).accountKindBasic;
        break;
      case AccountKind.multi:
        name = Strings.of(context).accountKindMulti;
        break;
    }

    return name;
  }
}

class AccountContainer extends StatelessWidget {
  const AccountContainer({
    required this.rows,
    required this.isSelected,
    required this.name,
    this.onShowMenu,
    Key? key,
  }) : super(key: key);

  static Key keyAccountEllipsisName(String name) =>
      ValueKey('$AccountContainer.ellipsis_$name');

  final List<Widget> rows;
  final void Function()? onShowMenu;
  final bool isSelected;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.only(
              left: Spacing.xLarge,
              top: Spacing.large,
              bottom: Spacing.large,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              textDirection: TextDirection.ltr,
              children: rows,
            ),
          ),
        ),
        if (onShowMenu != null)
          GestureDetector(
            key: keyAccountEllipsisName(name),
            behavior: HitTestBehavior.opaque,
            onTap: onShowMenu,
            child: SizedBox(
              width: 60,
              height: 60,
              child: Center(
                child: PwIcon(
                  PwIcons.ellipsis,
                  color: Theme.of(context).colorScheme.neutralNeutral,
                ),
              ),
            ),
          ),
        VerticalSpacer.medium(),
      ],
    );
  }
}

class AccountDescriptionRow extends StatelessWidget {
  const AccountDescriptionRow({
    required this.account,
    required this.isSelected,
    Key? key,
  }) : super(key: key);

  final bool isSelected;
  final TransactableAccount account;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int?>(
      future: Provider.of<AccountsBloc>(context, listen: false)
          .getAssetCount(account),
      builder: (context, snapshot) {
        final numAssets = snapshot.data;

        var text = '';
        if (isSelected) {
          text += Strings.of(context).selectedAccountLabel;
        }

        if (numAssets != null) {
          if (isSelected) {
            text += ' ${Strings.dotSeparator} ';
          }

          text += Strings.of(context).nAssets(numAssets);
        }

        return Container(
          margin: EdgeInsets.only(
            top: 4,
          ),
          child: PwText(
            text,
            style: PwTextStyle.bodySmall,
            color: PwColor.neutralNeutral,
            overflow: TextOverflow.fade,
            softWrap: true,
          ),
        );
      },
    );
  }
}

class AccountNetworkRow extends StatelessWidget {
  const AccountNetworkRow({
    required this.coin,
    Key? key,
  }) : super(key: key);

  final Coin coin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: 4,
      ),
      child: PwText(
        coin.displayName,
        style: PwTextStyle.bodySmall,
      ),
    );
  }
}

class LinkedAccount extends StatelessWidget {
  const LinkedAccount({
    required this.name,
    required this.isSelected,
    Key? key,
  }) : super(key: key);

  final String name;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: Spacing.large,
        horizontal: Spacing.xLarge,
      ),
      child: Row(
        children: [
          PwIcon(
            PwIcons.linked,
            color: isSelected
                ? Theme.of(context).colorScheme.secondary350
                : Theme.of(context).colorScheme.neutralNeutral,
            size: 24,
          ),
          HorizontalSpacer.large(),
          Expanded(
            child: PwText(
              Strings.of(context).accountLinkedTo(name),
              style: PwTextStyle.footnote,
              color: PwColor.neutralNeutral,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_autosizing_text.dart';
import 'package:provenance_wallet/screens/home/home_bloc.dart';
import 'package:provenance_wallet/screens/receive_flow/receive_flow.dart';
import 'package:provenance_wallet/screens/send_flow/send_flow.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/models/asset.dart';
import 'package:provenance_wallet/util/extensions/double_extensions.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:provider/provider.dart';

typedef OnAddressCaptured = Future<void> Function(String address);

class AccountPortfolio extends StatelessWidget {
  const AccountPortfolio({Key? key, this.labelHeight = 45.0}) : super(key: key);

  final double labelHeight;

  static final keySendButton = ValueKey('$AccountPortfolio.send_button');

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<HomeBloc>(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.large,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PwText(
            Strings.of(context).portfolioValue,
            color: PwColor.neutralNeutral,
            style: PwTextStyle.title,
          ),
          StreamBuilder<List<Asset>?>(
            initialData: bloc.assetList.value,
            stream: bloc.assetList,
            builder: (context, snapshot) {
              if (snapshot.data == null) {
                return PwText(
                  "",
                  color: PwColor.neutralNeutral,
                  style: PwTextStyle.display1,
                );
              }
              double portfolioValue = 0;

              if (snapshot.data!.isNotEmpty) {
                portfolioValue = snapshot.data
                        ?.map((e) => e.usdPrice * double.parse(e.amount))
                        .reduce((value, element) => value + element) ??
                    0;
              }

              return PwAutoSizingText(
                portfolioValue.toCurrency(),
                color: PwColor.neutralNeutral,
                style: PwTextStyle.display1,
                height: labelHeight,
              );
            },
          ),
          VerticalSpacer.xLarge(),
          Row(
            children: [
              Flexible(
                child: PwButton(
                  key: AccountPortfolio.keySendButton,
                  minimumHeight: 66,
                  child: Column(
                    children: [
                      PwIcon.only(
                        PwIcons.upArrow,
                        width: 14,
                        height: 16,
                        color: Theme.of(context).colorScheme.neutralNeutral,
                      ),
                      VerticalSpacer.xSmall(),
                      PwText(
                        Strings.of(context).send,
                        color: PwColor.neutralNeutral,
                        style: PwTextStyle.bodyBold,
                      ),
                    ],
                  ),
                  onPressed: () async {
                    final accountDetails =
                        await get<AccountService>().getSelectedAccount();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SendFlow(accountDetails!),
                      ),
                    );
                  },
                ),
              ),
              HorizontalSpacer.small(),
              Flexible(
                child: PwButton(
                  //minimumWidth: 150,
                  minimumHeight: 66,
                  child: Column(
                    children: [
                      PwIcon.only(
                        PwIcons.downArrow,
                        width: 14,
                        height: 16,
                        color: Theme.of(context).colorScheme.neutralNeutral,
                      ),
                      VerticalSpacer.xSmall(),
                      PwText(
                        Strings.of(context).receive,
                        color: PwColor.neutralNeutral,
                        style: PwTextStyle.bodyBold,
                      ),
                    ],
                  ),
                  onPressed: () {
                    final accountDetails =
                        get<AccountService>().events.selected.value;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReceiveFlow(accountDetails!),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

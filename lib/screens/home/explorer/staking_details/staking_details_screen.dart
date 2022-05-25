import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/home/transactions/details_item.dart';

class StakingDetailsScreen extends StatefulWidget {
  const StakingDetailsScreen({
    Key? key,
    required this.validatorAddress,
  }) : super(key: key);

  final String validatorAddress;

  @override
  State<StatefulWidget> createState() => StakingDetailsScreenState();
}

class StakingDetailsScreenState extends State<StakingDetailsScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PwAppBar(
        title: "Validator Details",
        leadingIcon: PwIcons.back,
      ),
      body: Container(
        color: Theme.of(context).colorScheme.neutral750,
        child: ListView(
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: Spacing.largeX3,
                vertical: Spacing.xLarge,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundImage: NetworkImage(""),
                          child: PwText("F"),
                        ),
                        VerticalSpacer.large(),
                        PwText(
                          "Figure",
                          style: PwTextStyle.bodyBold,
                        ),
                        VerticalSpacer.large(),
                        // Description, might be empty string.
                        PwText(
                          "Figure's primary testnet validator",
                          style: PwTextStyle.body,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            PwListDivider(
              indent: Spacing.largeX3,
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: Spacing.largeX3,
                vertical: Spacing.xLarge,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  PwText(
                    "Active",
                    style: PwTextStyle.body,
                    color: PwColor.primaryP500,
                  ),
                  Expanded(child: Container()),
                  Flexible(
                    child: PwButton(
                      child: PwText(
                        "Delegate",
                        style: PwTextStyle.body,
                      ),
                      onPressed: () {
                        // TODO: Delegate modal here.
                      },
                    ),
                  ),
                ],
              ),
            ),
            PwListDivider(
              indent: Spacing.largeX3,
            ),
            DetailsItem(
              title: "Operator Address",
              endChild: PwText(
                "tpv...ajn843fe",
                style: PwTextStyle.body,
              ),
            ),
            PwListDivider(
              indent: Spacing.largeX3,
            ),
            DetailsItem(
              title: "Owner Address",
              endChild: PwText(
                "tpv...ajn843fe",
                style: PwTextStyle.body,
              ),
            ),
            PwListDivider(
              indent: Spacing.largeX3,
            ),
            DetailsItem(
              title: "Withdraw Address",
              endChild: PwText(
                "tpv...ajn843fe",
                style: PwTextStyle.body,
              ),
            ),
            PwListDivider(
              indent: Spacing.largeX3,
            ),
            DetailsItem(
              title: "Voting Power",
              endChild: PwText(
                "25.34%",
                style: PwTextStyle.body,
              ),
            ),
            PwListDivider(
              indent: Spacing.largeX3,
            ),
            DetailsItem(
              title: "Uptime",
              endChild: PwText(
                "100%",
                style: PwTextStyle.body,
              ),
            ),
            PwListDivider(
              indent: Spacing.largeX3,
            ),
            DetailsItem(
              title: "Missed Blocks",
              endChild: PwText(
                "0 in 8640", // "${blockCount.count} in ${blockCount.total}"
                style: PwTextStyle.body,
              ),
            ),
            PwListDivider(
              indent: Spacing.largeX3,
            ),
            DetailsItem(
              title: "Bond Height",
              endChild: PwText(
                "0",
              ),
            ),
            PwListDivider(
              indent: Spacing.largeX3,
            ),
            DetailsItem(
              title: "Consensus Pubkey",
              endChild: PwText(
                "tpv...2mmr9w8m",
              ),
            ),
            PwListDivider(
              indent: Spacing.largeX3,
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Spacing.largeX3,
                vertical: Spacing.xLarge,
              ),
              child: PwText("Commission Info", style: PwTextStyle.title),
            ),
            PwListDivider(
              indent: Spacing.largeX3,
            ),
            DetailsItem(
              title: "Commission Rate",
              endChild: PwText(
                "100%",
              ),
            ),
            PwListDivider(
              indent: Spacing.largeX3,
            ),
            DetailsItem(
              title: "Delegators",
              endChild: PwText(
                "19",
              ),
            ),
            PwListDivider(
              indent: Spacing.largeX3,
            ),
            DetailsItem(
              title: "Rewards",
              endChild: PwText(
                "1,353,929.9699911 hash",
              ),
            ),
            PwListDivider(
              indent: Spacing.largeX3,
            ),
            DetailsItem(
              title: "Max Change Rate",
              endChild: PwText(
                "100%",
              ),
            ),
            PwListDivider(
              indent: Spacing.largeX3,
            ),
            DetailsItem(
              title: "Bonded",
              endChild: PwText(
                "1,460,504,261.0999963 hash",
              ),
            ),
            PwListDivider(
              indent: Spacing.largeX3,
            ),
            DetailsItem(
              title: "Total Shares",
              endChild: PwText(
                "1,460,504,261,099,996,400",
              ),
            ),
            PwListDivider(
              indent: Spacing.largeX3,
            ),
            DetailsItem(
              title: "Commission Rate Range",
              endChild: PwText(
                "0 ~ 100 %",
              ),
            ),
            PwListDivider(
              indent: Spacing.largeX3,
            ),
          ],
        ),
      ),
    );
  }
}

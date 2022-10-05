import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/home/staking/staking_details/details_header.dart';
import 'package:provenance_wallet/screens/home/staking/staking_details/validator_card.dart';
import 'package:provenance_wallet/screens/home/staking/staking_redelegation/staking_redelegation_bloc.dart';
import 'package:provenance_wallet/screens/home/staking/staking_redelegation/staking_redelegation_list.dart';
import 'package:provenance_wallet/screens/home/transactions/details_item.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:provider/provider.dart';

class StakingRedelegationScreen extends StatefulWidget {
  const StakingRedelegationScreen({
    Key? key,
  }) : super(key: key);

  @override
  _StakingRedelegationScreenState createState() =>
      _StakingRedelegationScreenState();
}

class _StakingRedelegationScreenState extends State<StakingRedelegationScreen> {
  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<StakingRedelegationBloc>(context);
    final strings = Strings.of(context);
    return Container(
      color: Theme.of(context).colorScheme.neutral750,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return StreamBuilder<StakingRedelegationDetails>(
              initialData: bloc.stakingRedelegationDetails.value,
              stream: bloc.stakingRedelegationDetails,
              builder: (context, snapshot) {
                final details = snapshot.data;

                if (details == null) {
                  return Container();
                }
                return Scaffold(
                  appBar: AppBar(
                    primary: false,
                    backgroundColor: Theme.of(context).colorScheme.neutral750,
                    elevation: 0.0,
                    centerTitle: true,
                    title: PwText(
                      strings.stakingRedelegateRedelegate,
                      style: PwTextStyle.footnote,
                    ),
                    leading: IconButton(
                      icon: PwIcon(
                        PwIcons.back,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  body: ListView(
                    padding: EdgeInsets.symmetric(horizontal: Spacing.large),
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DetailsHeader(
                            title: strings.stakingRedelegateRedelegating,
                          ),
                          PwListDivider.alternate(),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: Spacing.small,
                            ),
                            child: PwText(
                              strings.stakingRedelegateFrom,
                              color: PwColor.neutral200,
                            ),
                          ),
                          ValidatorCard(
                            moniker: details.validator.moniker,
                            imgUrl: details.validator.imgUrl,
                            description: details.validator.description,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: Spacing.small,
                            ),
                            child: PwText(
                              strings.stakingRedelegateTo,
                              color: PwColor.neutral200,
                            ),
                          ),
                          ValidatorCard(),
                          VerticalSpacer.xLarge(),
                          PwText(
                            strings.stakingDelegateDetails,
                            style: PwTextStyle.subhead,
                          ),
                          VerticalSpacer.large(),
                          PwListDivider.alternate(),
                          DetailsItem.withHash(
                            title: strings
                                .stakingRedelegateAvailableForRedelegation,
                            hashString: details.delegation.displayDenom,
                            context: context,
                          ),
                          PwListDivider.alternate(),
                          SizedBox(
                            height: constraints.maxHeight - 55,
                            child: StakingRedelegationList(),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

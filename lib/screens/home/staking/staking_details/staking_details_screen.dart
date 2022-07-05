import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/home/staking/staking_details/details_header.dart';
import 'package:provenance_wallet/screens/home/staking/staking_details/details_item_copy.dart';
import 'package:provenance_wallet/screens/home/staking/staking_details/staking_details_bloc.dart';
import 'package:provenance_wallet/screens/home/staking/staking_details/staking_management.dart';
import 'package:provenance_wallet/screens/home/staking/staking_flow/staking_flow.dart';
import 'package:provenance_wallet/screens/home/staking/staking_screen_bloc.dart';
import 'package:provenance_wallet/screens/home/transactions/details_item.dart';
import 'package:provenance_wallet/services/models/account.dart';
import 'package:provenance_wallet/services/models/delegation.dart';
import 'package:provenance_wallet/services/models/rewards.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:url_launcher/url_launcher.dart';

class StakingDetailsScreen extends StatefulWidget {
  const StakingDetailsScreen({
    Key? key,
    required this.validatorAddress,
    required this.account,
    required this.selectedDelegation,
    required this.navigator,
    required this.rewards,
  }) : super(key: key);

  final String validatorAddress;
  final Account account;
  final Delegation? selectedDelegation;
  final Rewards? rewards;
  final StakingFlowNavigator navigator;

  @override
  State<StatefulWidget> createState() => StakingDetailsScreenState();
}

class StakingDetailsScreenState extends State<StakingDetailsScreen> {
  late final StakingDetailsBloc _bloc;

  @override
  void initState() {
    _bloc = StakingDetailsBloc(
      widget.validatorAddress,
      widget.account,
      widget.selectedDelegation,
      widget.rewards,
    );
    _bloc.load();
    get.registerSingleton<StakingDetailsBloc>(_bloc);
    super.initState();
  }

  @override
  void dispose() {
    get.unregister<StakingDetailsBloc>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: Theme.of(context).colorScheme.neutral750,
          child: StreamBuilder<DetailedValidatorDetails>(
            initialData: _bloc.validatorDetails.value,
            stream: _bloc.validatorDetails,
            builder: (context, snapshot) {
              final details = snapshot.data;
              final validator = snapshot.data?.validator;
              final commission = snapshot.data?.commission;
              if (details == null || validator == null || commission == null) {
                return Container();
              }

              return Scaffold(
                appBar: PwAppBar(
                  title: validator.moniker,
                  leadingIcon: PwIcons.back,
                  style: PwTextStyle.footnote,
                ),
                body: ListView(
                  padding: EdgeInsets.symmetric(horizontal: Spacing.large),
                  children: [
                    DetailsHeader(
                      title: Strings.stakingDetailsDelegationStatus,
                    ),
                    PwListDivider.alternate(context: context),
                    DetailsItem.withHash(
                      title: Strings.stakingManagementMyDelegation,
                      hashString: details.delegation?.displayDenom ??
                          Strings.stakingManagementNoHash,
                      context: context,
                    ),
                    PwListDivider.alternate(context: context),
                    if (details.rewards == null ||
                        details.rewards?.rewards.isEmpty == true)
                      DetailsItem.withHash(
                        title: Strings.stakingDetailsRewards,
                        hashString: Strings.stakingManagementNoHash,
                        context: context,
                      ),
                    if (details.rewards != null &&
                        details.rewards!.rewards.isNotEmpty)
                      for (var reward in details.rewards!.rewards)
                        DetailsItem.withHash(
                          title: Strings.stakingDetailsRewards,
                          hashString: '${reward.amount} ${reward.denom}',
                          context: context,
                        ),
                    PwListDivider.alternate(context: context),
                    DetailsItem.withRowChildren(
                      title: Strings.stakingDetailsStatus,
                      children: [
                        Icon(
                          Icons.brightness_1,
                          color: get<StakingScreenBloc>()
                              .getColor(validator.status, context),
                          size: 8,
                        ),
                        HorizontalSpacer.xSmall(),
                        PwText(
                          validator.status.name.capitalize(),
                          style: PwTextStyle.footnote,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                        )
                      ],
                    ),
                    PwListDivider.alternate(context: context),
                    DetailsHeader(
                      title: Strings.stakingDetailsCommissionInformation,
                    ),
                    PwListDivider.alternate(context: context),
                    DetailsItem.withHash(
                      title: Strings.stakingDetailsBonded,
                      hashString: commission.formattedBondedTokens,
                      context: context,
                    ),
                    PwListDivider.alternate(context: context),
                    DetailsItem.alternateStrings(
                      title: Strings.stakingDetailsCommissionRateRange,
                      value: "0 ~ ${commission.commissionMaxRate}",
                    ),
                    PwListDivider.alternate(context: context),
                    DetailsItem.alternateStrings(
                      title: Strings.stakingDetailsCommissionRate,
                      value: commission.commissionMaxRate,
                    ),
                    PwListDivider.alternate(context: context),
                    DetailsItem.alternateStrings(
                      title: Strings.stakingDetailsDelegators,
                      value: commission.delegatorCount.toString(),
                    ),
                    PwListDivider.alternate(context: context),
                    DetailsItem.alternateStrings(
                      title: Strings.stakingDetailsMaxChangeRate,
                      value: commission.commissionMaxChangeRate,
                    ),
                    PwListDivider.alternate(context: context),
                    DetailsItem.alternateStrings(
                      title: Strings.stakingDetailsMissedBlocks,
                      value:
                          "${validator.blockCount} in ${validator.blockTotal}",
                    ),
                    PwListDivider.alternate(context: context),
                    DetailsItem.alternateStrings(
                      title: Strings.stakingDetailsRewards,
                      value: commission.formattedRewards,
                    ),
                    PwListDivider.alternate(context: context),
                    DetailsItem.alternateStrings(
                      title: Strings.stakingDetailsTotalShares,
                      value: commission.formattedTotalShares,
                    ),
                    PwListDivider.alternate(context: context),
                    DetailsItem.withRowChildren(
                      title: Strings.stakingDetailsValidatorTransactions,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            String url = _bloc.getProvUrl();
                            if (await canLaunch(url)) {
                              await launch(url);
                            } else {
                              throw 'Could not launch $url';
                            }
                          },
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: PwIcon(
                              PwIcons.newWindow,
                              color:
                                  Theme.of(context).colorScheme.neutralNeutral,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    PwListDivider.alternate(context: context),
                    DetailsHeader(title: Strings.stakingDetailsAddresses),
                    PwListDivider.alternate(context: context),
                    DetailsItemCopy(
                      displayTitle: Strings.stakingDetailsOperatorAddress,
                      dataToCopy: validator.operatorAddress,
                      snackBarTitle:
                          Strings.stakingDetailsOperatorAddressCopied,
                    ),
                    PwListDivider.alternate(context: context),
                    DetailsItemCopy(
                      displayTitle: Strings.stakingDetailsOwnerAddress,
                      dataToCopy: validator.ownerAddress,
                      snackBarTitle: Strings.stakingDetailsOwnerAddressCopied,
                    ),
                    PwListDivider.alternate(context: context),
                    DetailsItemCopy(
                      displayTitle: Strings.stakingDetailsWithdrawAddress,
                      dataToCopy: validator.withdrawalAddress,
                      snackBarTitle:
                          Strings.stakingDetailsWithdrawAddressCopied,
                    ),
                    PwListDivider.alternate(context: context),
                    DetailsItemCopy(
                      displayTitle: Strings.stakingDetailsConsensusPubkey,
                      dataToCopy: validator.consensusPubKey,
                      snackBarTitle:
                          Strings.stakingDetailsConsensusPubkeyCopied,
                    ),
                    PwListDivider.alternate(context: context),
                    DetailsHeader(
                        title: Strings.stakingDetailsAdditionalDetails),
                    PwListDivider.alternate(context: context),
                    DetailsItem.alternateStrings(
                      title: Strings.stakingDetailsBondHeight,
                      value: validator.bondHeight.toString(),
                    ),
                    PwListDivider.alternate(context: context),
                    DetailsItem.alternateStrings(
                      title: Strings.stakingDetailsUptime,
                      value: "${validator.uptime}%",
                    ),
                    PwListDivider.alternate(context: context),
                    DetailsItem.alternateStrings(
                      title: Strings.stakingDetailsVotingPower,
                      value: validator.formattedVotingPower,
                    ),
                    if (ValidatorStatus.jailed == validator.status)
                      PwListDivider.alternate(context: context),
                    if (ValidatorStatus.jailed == validator.status)
                      DetailsItem.alternateStrings(
                        title: Strings.stakingDetailsJailedUntil,
                        value: validator.formattedJailedUntil,
                      ),
                    if (ValidatorStatus.jailed == validator.status)
                      PwListDivider.alternate(context: context),
                    if (ValidatorStatus.jailed == validator.status)
                      DetailsItem.alternateStrings(
                        title: Strings.stakingDetailsUnbondingHeight,
                        value: (validator.unbondingHeight ?? 0).toString(),
                      ),
                    if (details.delegation != null)
                      StakingManagement(
                        navigator: widget.navigator,
                        delegation: details.delegation!,
                        commission: commission,
                        validator: validator,
                      ),
                  ],
                ),
              );
            },
          ),
        ),
        StreamBuilder<bool>(
          initialData: _bloc.isLoading.value,
          stream: _bloc.isLoading,
          builder: (context, snapshot) {
            final isLoading = snapshot.data ?? false;
            if (isLoading) {
              return SizedBox(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            return Container();
          },
        ),
      ],
    );
  }
}

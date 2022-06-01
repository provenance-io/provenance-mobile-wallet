import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/home/explorer/explorer_bloc.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_details/details_item_copy.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_details/staking_details_bloc.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_flow.dart';
import 'package:provenance_wallet/screens/home/transactions/details_item.dart';
import 'package:provenance_wallet/services/models/account_details.dart';
import 'package:provenance_wallet/services/models/delegation.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:url_launcher/url_launcher.dart';

class StakingDetailsScreen extends StatefulWidget {
  const StakingDetailsScreen({
    Key? key,
    required this.validatorAddress,
    required this.details,
    required this.selectedDelegation,
    required this.navigator,
  }) : super(key: key);

  final String validatorAddress;
  final AccountDetails details;
  final Delegation? selectedDelegation;
  final StakingFlowBlocNavigator navigator;

  @override
  State<StatefulWidget> createState() => StakingDetailsScreenState();
}

class StakingDetailsScreenState extends State<StakingDetailsScreen> {
  late final StakingDetailsBloc _bloc;

  @override
  void initState() {
    _bloc = StakingDetailsBloc(
      widget.validatorAddress,
      widget.details,
      widget.selectedDelegation,
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
    return Scaffold(
        appBar: PwAppBar(
          title: Strings.stakingDetailsValidatorDetails,
          leadingIcon: PwIcons.back,
        ),
        body: Stack(
          children: [
            Container(
              color: Theme.of(context).colorScheme.neutral750,
              child: StreamBuilder<DetailedValidatorDetails>(
                initialData: _bloc.validatorDetails.value,
                stream: _bloc.validatorDetails,
                builder: (context, snapshot) {
                  final validator = snapshot.data?.validator;
                  final commission = snapshot.data?.commission;
                  if (validator == null || commission == null) {
                    return Container();
                  }

                  return ListView(
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
                                    backgroundColor:
                                        Theme.of(context).primaryColor,
                                    foregroundImage:
                                        NetworkImage(validator.imgUrl ?? ""),
                                    child: PwText(validator.moniker
                                        .substring(0, 1)
                                        .toUpperCase()),
                                  ),
                                  VerticalSpacer.large(),
                                  PwText(
                                    validator.moniker,
                                    style: PwTextStyle.bodyBold,
                                  ),
                                  if (validator.description.isNotEmpty)
                                    VerticalSpacer.large(),
                                  // Description, might be empty string.
                                  if (validator.description.isNotEmpty)
                                    PwText(
                                      validator.description,
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
                              validator.status.name.capitalize(),
                              style: PwTextStyle.body,
                              color: _bloc.getColor(validator.status),
                            ),
                            Expanded(child: Container()),
                            Flexible(
                              child: PwButton(
                                child: PwText(
                                  Strings.stakingDetailsButtonDelegate,
                                  style: PwTextStyle.body,
                                ),
                                onPressed: () async {
                                  widget.navigator.showDelegationManagement(
                                    validator,
                                    commission,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      PwListDivider(
                        indent: Spacing.largeX3,
                      ),
                      DetailsItemCopy(
                        displayTitle: Strings.stakingDetailsOperatorAddress,
                        dataToCopy: validator.operatorAddress,
                        snackBarTitle:
                            Strings.stakingDetailsOperatorAddressCopied,
                      ),
                      PwListDivider(
                        indent: Spacing.largeX3,
                      ),
                      DetailsItemCopy(
                        displayTitle: Strings.stakingDetailsOwnerAddress,
                        dataToCopy: validator.ownerAddress,
                        snackBarTitle: Strings.stakingDetailsOwnerAddressCopied,
                      ),
                      PwListDivider(
                        indent: Spacing.largeX3,
                      ),
                      DetailsItemCopy(
                        displayTitle: Strings.stakingDetailsWithdrawAddress,
                        dataToCopy: validator.withdrawalAddress,
                        snackBarTitle:
                            Strings.stakingDetailsWithdrawAddressCopied,
                      ),
                      PwListDivider(
                        indent: Spacing.largeX3,
                      ),
                      if (ValidatorStatus.jailed == validator.status)
                        DetailsItem(
                          title: Strings.stakingDetailsUnbondingHeight,
                          endChild: PwText(
                            (validator.unbondingHeight ?? 0).toString(),
                            style: PwTextStyle.body,
                          ),
                        ),
                      if (ValidatorStatus.jailed == validator.status)
                        PwListDivider(
                          indent: Spacing.largeX3,
                        ),
                      if (validator.formattedVotingPower.isNotEmpty &&
                          ValidatorStatus.jailed != validator.status)
                        DetailsItem(
                          title: Strings.stakingDetailsVotingPower,
                          endChild: PwText(
                            validator.formattedVotingPower,
                            style: PwTextStyle.body,
                          ),
                        ),
                      if (validator.formattedVotingPower.isNotEmpty &&
                          ValidatorStatus.jailed != validator.status)
                        PwListDivider(
                          indent: Spacing.largeX3,
                        ),
                      if (ValidatorStatus.jailed != validator.status)
                        DetailsItem(
                          title: Strings.stakingDetailsUptime,
                          endChild: PwText(
                            "${validator.uptime}%",
                            style: PwTextStyle.body,
                          ),
                        ),
                      if (ValidatorStatus.jailed != validator.status)
                        PwListDivider(
                          indent: Spacing.largeX3,
                        ),
                      if (ValidatorStatus.jailed != validator.status)
                        DetailsItem(
                          title: Strings.stakingDetailsMissedBlocks,
                          endChild: PwText(
                            "${validator.blockCount} in ${validator.blockTotal}",
                            style: PwTextStyle.body,
                          ),
                        ),
                      if (ValidatorStatus.jailed != validator.status)
                        PwListDivider(
                          indent: Spacing.largeX3,
                        ),
                      if (ValidatorStatus.jailed != validator.status)
                        DetailsItem(
                          title: Strings.stakingDetailsBondHeight,
                          endChild: PwText(
                            validator.bondHeight.toString(),
                          ),
                        ),
                      if (ValidatorStatus.jailed != validator.status)
                        PwListDivider(
                          indent: Spacing.largeX3,
                        ),
                      DetailsItemCopy(
                        displayTitle: Strings.stakingDetailsConsensusPubkey,
                        dataToCopy: validator.consensusPubKey,
                        snackBarTitle:
                            Strings.stakingDetailsConsensusPubkeyCopied,
                      ),
                      PwListDivider(
                        indent: Spacing.largeX3,
                      ),
                      if (ValidatorStatus.jailed == validator.status)
                        DetailsItem(
                          title: Strings.stakingDetailsJailedUntil,
                          endChild: PwText(
                            validator.formattedJailedUntil,
                            style: PwTextStyle.body,
                          ),
                        ),
                      if (ValidatorStatus.jailed == validator.status)
                        PwListDivider(
                          indent: Spacing.largeX3,
                        ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: Spacing.largeX3,
                          vertical: Spacing.xLarge,
                        ),
                        child: PwText(
                          Strings.stakingDetailsCommissionInfo,
                          style: PwTextStyle.title,
                        ),
                      ),
                      PwListDivider(
                        indent: Spacing.largeX3,
                      ),
                      DetailsItem(
                        title: Strings.stakingDetailsCommissionRate,
                        endChild: PwText(
                          commission.commissionRate,
                        ),
                      ),
                      PwListDivider(
                        indent: Spacing.largeX3,
                      ),
                      DetailsItem(
                        title: Strings.stakingDetailsDelegators,
                        endChild: PwText(
                          commission.delegatorCount.toString(),
                        ),
                      ),
                      PwListDivider(
                        indent: Spacing.largeX3,
                      ),
                      DetailsItem(
                        title: Strings.stakingDetailsRewards,
                        endChild: PwText(
                          commission.formattedRewards,
                        ),
                      ),
                      PwListDivider(
                        indent: Spacing.largeX3,
                      ),
                      DetailsItem(
                        title: Strings.stakingDetailsMaxChangeRate,
                        endChild: PwText(
                          commission.commissionMaxChangeRate,
                        ),
                      ),
                      PwListDivider(
                        indent: Spacing.largeX3,
                      ),
                      DetailsItem(
                        title: Strings.stakingDetailsBonded,
                        endChild: PwText(
                          commission.formattedBondedTokens,
                        ),
                      ),
                      PwListDivider(
                        indent: Spacing.largeX3,
                      ),
                      DetailsItem(
                        title: Strings.stakingDetailsTotalShares,
                        endChild: PwText(
                          commission.formattedTotalShares,
                        ),
                      ),
                      PwListDivider(
                        indent: Spacing.largeX3,
                      ),
                      DetailsItem(
                        title: Strings.stakingDetailsCommissionRateRange,
                        endChild: PwText(
                          "0 ~ ${commission.commissionMaxRate}",
                        ),
                      ),
                      PwListDivider(
                        indent: Spacing.largeX3,
                      ),
                      DetailsItem(
                        title: Strings.stakingDetailsValidatorTransactions,
                        endChild: GestureDetector(
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
                      ),
                    ],
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
        ));
  }
}

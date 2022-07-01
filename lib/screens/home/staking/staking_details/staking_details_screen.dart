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
                    _getDivider(context),
                    _getHashDetails(
                      Strings.stakingManagementMyDelegation,
                      details.delegation?.displayDenom ??
                          Strings.stakingManagementNoHash,
                    ),
                    _getDivider(context),
                    if (details.rewards == null ||
                        details.rewards?.rewards.isEmpty == true)
                      _getHashDetails(Strings.stakingDetailsRewards,
                          Strings.stakingManagementNoHash),
                    if (details.rewards != null &&
                        details.rewards!.rewards.isNotEmpty)
                      for (var reward in details.rewards!.rewards)
                        _getHashDetails(Strings.stakingDetailsRewards,
                            '${reward.amount} ${reward.denom}'),
                    _getDivider(context),
                    _getDetailsItem(
                      Strings.stakingDetailsStatus,
                      [
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
                    _getDivider(context),
                    DetailsHeader(
                      title: Strings.stakingDetailsCommissionInformation,
                    ),
                    _getDivider(context),
                    _getHashDetails(
                      Strings.stakingDetailsBonded,
                      commission.formattedBondedTokens,
                    ),
                    _getDivider(context),
                    _getStringDetailsItem(
                      Strings.stakingDetailsCommissionRateRange,
                      "0 ~ ${commission.commissionMaxRate}",
                    ),
                    _getDivider(context),
                    _getStringDetailsItem(
                      Strings.stakingDetailsCommissionRate,
                      commission.commissionMaxRate,
                    ),
                    _getDivider(context),
                    _getStringDetailsItem(
                      Strings.stakingDetailsDelegators,
                      commission.delegatorCount.toString(),
                    ),
                    _getDivider(context),
                    _getStringDetailsItem(
                      Strings.stakingDetailsMaxChangeRate,
                      commission.commissionMaxChangeRate,
                    ),
                    _getDivider(context),
                    _getStringDetailsItem(
                      Strings.stakingDetailsMissedBlocks,
                      "${validator.blockCount} in ${validator.blockTotal}",
                    ),
                    _getDivider(context),
                    _getStringDetailsItem(
                      Strings.stakingDetailsRewards,
                      commission.formattedRewards,
                    ),
                    _getDivider(context),
                    _getStringDetailsItem(
                      Strings.stakingDetailsTotalShares,
                      commission.formattedTotalShares,
                    ),
                    _getDivider(context),
                    _getDetailsItem(
                      Strings.stakingDetailsValidatorTransactions,
                      [
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
                    _getDivider(context),
                    DetailsHeader(title: Strings.stakingDetailsAddresses),
                    _getDivider(context),
                    DetailsItemCopy(
                      displayTitle: Strings.stakingDetailsOperatorAddress,
                      dataToCopy: validator.operatorAddress,
                      snackBarTitle:
                          Strings.stakingDetailsOperatorAddressCopied,
                    ),
                    _getDivider(context),
                    DetailsItemCopy(
                      displayTitle: Strings.stakingDetailsOwnerAddress,
                      dataToCopy: validator.ownerAddress,
                      snackBarTitle: Strings.stakingDetailsOwnerAddressCopied,
                    ),
                    _getDivider(context),
                    DetailsItemCopy(
                      displayTitle: Strings.stakingDetailsWithdrawAddress,
                      dataToCopy: validator.withdrawalAddress,
                      snackBarTitle:
                          Strings.stakingDetailsWithdrawAddressCopied,
                    ),
                    _getDivider(context),
                    DetailsItemCopy(
                      displayTitle: Strings.stakingDetailsConsensusPubkey,
                      dataToCopy: validator.consensusPubKey,
                      snackBarTitle:
                          Strings.stakingDetailsConsensusPubkeyCopied,
                    ),
                    _getDivider(context),
                    DetailsHeader(
                        title: Strings.stakingDetailsAdditionalDetails),
                    _getDivider(context),
                    _getStringDetailsItem(
                      Strings.stakingDetailsBondHeight,
                      validator.bondHeight.toString(),
                    ),
                    _getDivider(context),
                    _getStringDetailsItem(
                      Strings.stakingDetailsUptime,
                      "${validator.uptime}%",
                    ),
                    _getDivider(context),
                    _getStringDetailsItem(
                      Strings.stakingDetailsVotingPower,
                      validator.formattedVotingPower,
                    ),
                    if (ValidatorStatus.jailed == validator.status)
                      _getDivider(context),
                    if (ValidatorStatus.jailed == validator.status)
                      _getStringDetailsItem(
                        Strings.stakingDetailsJailedUntil,
                        validator.formattedJailedUntil,
                      ),
                    if (ValidatorStatus.jailed == validator.status)
                      _getDivider(context),
                    if (ValidatorStatus.jailed == validator.status)
                      _getStringDetailsItem(
                        Strings.stakingDetailsUnbondingHeight,
                        (validator.unbondingHeight ?? 0).toString(),
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

  Widget _getHashDetails(String title, String hashString) {
    return _getDetailsItem(
      title,
      [
        PwIcon(
          PwIcons.hashLogo,
          size: 24,
          color: Theme.of(context).colorScheme.neutralNeutral,
        ),
        HorizontalSpacer.small(),
        PwText(
          hashString,
          overflow: TextOverflow.fade,
          softWrap: false,
          style: PwTextStyle.footnote,
        ),
      ],
    );
  }

  Widget _getDetailsItem(String title, List<Widget> children) {
    return DetailsItem(
      title: title,
      padding: EdgeInsets.symmetric(vertical: Spacing.large),
      style: PwTextStyle.footnote,
      color: PwColor.neutral200,
      endChild: children.length == 1
          ? children.first
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: children,
            ),
    );
  }

  Widget _getStringDetailsItem(String title, String value) {
    return DetailsItem.fromStrings(
      padding: EdgeInsets.symmetric(vertical: Spacing.large),
      color: PwColor.neutral200,
      style: PwTextStyle.footnote,
      title: title,
      value: value,
    );
  }

  Widget _getDivider(BuildContext context) {
    return PwListDivider(
      color: Theme.of(context).colorScheme.neutral700,
    );
  }
}

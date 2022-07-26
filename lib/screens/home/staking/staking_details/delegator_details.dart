import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/home/staking/staking_details/details_header.dart';
import 'package:provenance_wallet/screens/home/staking/staking_details/details_item_copy.dart';
import 'package:provenance_wallet/screens/home/staking/staking_details/staking_details_bloc.dart';
import 'package:provenance_wallet/screens/home/staking/staking_screen_bloc.dart';
import 'package:provenance_wallet/screens/home/transactions/details_item.dart';
import 'package:provenance_wallet/util/extensions/string_extensions.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:url_launcher/url_launcher.dart';

class DelegatorDetails extends StatelessWidget {
  final DetailedValidatorDetails details;

  const DelegatorDetails({
    Key? key,
    required this.details,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _bloc = get<StakingDetailsBloc>();
    final strings = Strings.of(context);
    return StreamBuilder<DetailedValidatorDetails>(
        initialData: _bloc.validatorDetails.value,
        stream: _bloc.validatorDetails,
        builder: (context, snapshot) {
          final details = snapshot.data;
          final validator = snapshot.data?.validator;
          final commission = snapshot.data?.commission;
          if (details == null || validator == null || commission == null) {
            return Container();
          }

          return Column(
            children: [
              DetailsHeader(
                title: strings.stakingDetailsDelegationStatus,
              ),
              PwListDivider.alternate(),
              DetailsItem.withHash(
                title: strings.stakingManagementMyDelegation,
                hashString: details.delegation?.displayDenom ??
                    strings.stakingManagementNoHash,
                context: context,
              ),
              PwListDivider.alternate(),
              if (details.rewards == null ||
                  details.rewards?.rewards.isEmpty == true)
                DetailsItem.withHash(
                  title: strings.stakingDetailsRewards,
                  hashString: strings.stakingManagementNoHash,
                  context: context,
                ),
              if (details.rewards != null &&
                  details.rewards!.rewards.isNotEmpty)
                for (var reward in details.rewards!.rewards)
                  DetailsItem.withHash(
                    title: strings.stakingDetailsRewards,
                    hashString: '${reward.amount} ${reward.denom}',
                    context: context,
                  ),
              PwListDivider.alternate(),
              DetailsItem.withRowChildren(
                title: strings.stakingDetailsStatus,
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
              PwListDivider.alternate(),
              DetailsHeader(
                title: strings.stakingDetailsCommissionInformation,
              ),
              PwListDivider.alternate(),
              DetailsItem.withHash(
                title: strings.stakingDetailsBonded,
                hashString: Strings.of(context)
                    .hashAmount(commission.formattedBondedTokens),
                context: context,
              ),
              PwListDivider.alternate(),
              DetailsItem.fromStrings(
                title: strings.stakingDetailsCommissionRateRange,
                value: "0 ~ ${commission.commissionMaxRate}",
              ),
              PwListDivider.alternate(),
              DetailsItem.fromStrings(
                title: strings.stakingDetailsCommissionRate,
                value: commission.commissionMaxRate,
              ),
              PwListDivider.alternate(),
              DetailsItem.fromStrings(
                title: strings.stakingDetailsDelegators,
                value: commission.delegatorCount.toString(),
              ),
              PwListDivider.alternate(),
              DetailsItem.fromStrings(
                title: strings.stakingDetailsMaxChangeRate,
                value: commission.commissionMaxChangeRate,
              ),
              PwListDivider.alternate(),
              DetailsItem.fromStrings(
                title: strings.stakingDetailsMissedBlocks,
                value: "${validator.blockCount} in ${validator.blockTotal}",
              ),
              PwListDivider.alternate(),
              DetailsItem.fromStrings(
                title: strings.stakingDetailsRewards,
                value:
                    Strings.of(context).hashAmount(commission.formattedRewards),
              ),
              PwListDivider.alternate(),
              DetailsItem.fromStrings(
                title: strings.stakingDetailsTotalShares,
                value: commission.formattedTotalShares,
              ),
              PwListDivider.alternate(),
              DetailsItem.withRowChildren(
                title: strings.stakingDetailsValidatorTransactions,
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
                        color: Theme.of(context).colorScheme.neutralNeutral,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              PwListDivider.alternate(),
              DetailsHeader(title: strings.stakingDetailsAddresses),
              PwListDivider.alternate(),
              DetailsItemCopy(
                displayTitle: strings.stakingDetailsOperatorAddress,
                dataToCopy: validator.operatorAddress,
                snackBarTitle: strings.stakingDetailsOperatorAddressCopied,
              ),
              PwListDivider.alternate(),
              DetailsItemCopy(
                displayTitle: strings.stakingDetailsOwnerAddress,
                dataToCopy: validator.ownerAddress,
                snackBarTitle: strings.stakingDetailsOwnerAddressCopied,
              ),
              PwListDivider.alternate(),
              DetailsItemCopy(
                displayTitle: strings.stakingDetailsWithdrawAddress,
                dataToCopy: validator.withdrawalAddress,
                snackBarTitle: strings.stakingDetailsWithdrawAddressCopied,
              ),
              PwListDivider.alternate(),
              DetailsItemCopy(
                displayTitle: strings.stakingDetailsConsensusPubkey,
                dataToCopy: validator.consensusPubKey,
                snackBarTitle: strings.stakingDetailsConsensusPubkeyCopied,
              ),
              PwListDivider.alternate(),
              DetailsHeader(title: strings.stakingDetailsAdditionalDetails),
              PwListDivider.alternate(),
              DetailsItem.fromStrings(
                title: strings.stakingDetailsBondHeight,
                value: validator.bondHeight.toString(),
              ),
              PwListDivider.alternate(),
              DetailsItem.fromStrings(
                title: strings.stakingDetailsUptime,
                value: "${validator.uptime}%",
              ),
              PwListDivider.alternate(),
              DetailsItem.fromStrings(
                title: strings.stakingDetailsVotingPower,
                value: validator.formattedVotingPower,
              ),
              if (ValidatorStatus.jailed == validator.status)
                PwListDivider.alternate(),
              if (ValidatorStatus.jailed == validator.status)
                DetailsItem.fromStrings(
                  title: strings.stakingDetailsJailedUntil,
                  value: validator.formattedJailedUntil,
                ),
              if (ValidatorStatus.jailed == validator.status)
                PwListDivider.alternate(),
              if (ValidatorStatus.jailed == validator.status)
                DetailsItem.fromStrings(
                  title: strings.stakingDetailsUnbondingHeight,
                  value: (validator.unbondingHeight ?? 0).toString(),
                ),
            ],
          );
        });
  }
}

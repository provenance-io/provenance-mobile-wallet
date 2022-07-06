import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/home/staking/staking_details/details_header.dart';
import 'package:provenance_wallet/screens/home/staking/staking_details/details_item_copy.dart';
import 'package:provenance_wallet/screens/home/staking/staking_details/staking_details_bloc.dart';
import 'package:provenance_wallet/screens/home/staking/staking_screen_bloc.dart';
import 'package:provenance_wallet/screens/home/transactions/details_item.dart';
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
                title: Strings.stakingDetailsDelegationStatus,
              ),
              PwListDivider.alternate(),
              DetailsItem.withHash(
                title: Strings.stakingManagementMyDelegation,
                hashString: details.delegation?.displayDenom ??
                    Strings.stakingManagementNoHash,
                context: context,
              ),
              PwListDivider.alternate(),
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
              PwListDivider.alternate(),
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
              PwListDivider.alternate(),
              DetailsHeader(
                title: Strings.stakingDetailsCommissionInformation,
              ),
              PwListDivider.alternate(),
              DetailsItem.withHash(
                title: Strings.stakingDetailsBonded,
                hashString: commission.formattedBondedTokens,
                context: context,
              ),
              PwListDivider.alternate(),
              DetailsItem.alternateStrings(
                title: Strings.stakingDetailsCommissionRateRange,
                value: "0 ~ ${commission.commissionMaxRate}",
              ),
              PwListDivider.alternate(),
              DetailsItem.alternateStrings(
                title: Strings.stakingDetailsCommissionRate,
                value: commission.commissionMaxRate,
              ),
              PwListDivider.alternate(),
              DetailsItem.alternateStrings(
                title: Strings.stakingDetailsDelegators,
                value: commission.delegatorCount.toString(),
              ),
              PwListDivider.alternate(),
              DetailsItem.alternateStrings(
                title: Strings.stakingDetailsMaxChangeRate,
                value: commission.commissionMaxChangeRate,
              ),
              PwListDivider.alternate(),
              DetailsItem.alternateStrings(
                title: Strings.stakingDetailsMissedBlocks,
                value: "${validator.blockCount} in ${validator.blockTotal}",
              ),
              PwListDivider.alternate(),
              DetailsItem.alternateStrings(
                title: Strings.stakingDetailsRewards,
                value: commission.formattedRewards,
              ),
              PwListDivider.alternate(),
              DetailsItem.alternateStrings(
                title: Strings.stakingDetailsTotalShares,
                value: commission.formattedTotalShares,
              ),
              PwListDivider.alternate(),
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
                        color: PwColor.neutralNeutral,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              PwListDivider.alternate(),
              DetailsHeader(title: Strings.stakingDetailsAddresses),
              PwListDivider.alternate(),
              DetailsItemCopy(
                displayTitle: Strings.stakingDetailsOperatorAddress,
                dataToCopy: validator.operatorAddress,
                snackBarTitle: Strings.stakingDetailsOperatorAddressCopied,
              ),
              PwListDivider.alternate(),
              DetailsItemCopy(
                displayTitle: Strings.stakingDetailsOwnerAddress,
                dataToCopy: validator.ownerAddress,
                snackBarTitle: Strings.stakingDetailsOwnerAddressCopied,
              ),
              PwListDivider.alternate(),
              DetailsItemCopy(
                displayTitle: Strings.stakingDetailsWithdrawAddress,
                dataToCopy: validator.withdrawalAddress,
                snackBarTitle: Strings.stakingDetailsWithdrawAddressCopied,
              ),
              PwListDivider.alternate(),
              DetailsItemCopy(
                displayTitle: Strings.stakingDetailsConsensusPubkey,
                dataToCopy: validator.consensusPubKey,
                snackBarTitle: Strings.stakingDetailsConsensusPubkeyCopied,
              ),
              PwListDivider.alternate(),
              DetailsHeader(title: Strings.stakingDetailsAdditionalDetails),
              PwListDivider.alternate(),
              DetailsItem.alternateStrings(
                title: Strings.stakingDetailsBondHeight,
                value: validator.bondHeight.toString(),
              ),
              PwListDivider.alternate(),
              DetailsItem.alternateStrings(
                title: Strings.stakingDetailsUptime,
                value: "${validator.uptime}%",
              ),
              PwListDivider.alternate(),
              DetailsItem.alternateStrings(
                title: Strings.stakingDetailsVotingPower,
                value: validator.formattedVotingPower,
              ),
              if (ValidatorStatus.jailed == validator.status)
                PwListDivider.alternate(),
              if (ValidatorStatus.jailed == validator.status)
                DetailsItem.alternateStrings(
                  title: Strings.stakingDetailsJailedUntil,
                  value: validator.formattedJailedUntil,
                ),
              if (ValidatorStatus.jailed == validator.status)
                PwListDivider.alternate(),
              if (ValidatorStatus.jailed == validator.status)
                DetailsItem.alternateStrings(
                  title: Strings.stakingDetailsUnbondingHeight,
                  value: (validator.unbondingHeight ?? 0).toString(),
                ),
            ],
          );
        });
  }
}

import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/screens/home/staking/staking_flow/staking_flow.dart';
import 'package:provenance_wallet/screens/home/staking/staking_screen_bloc.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/models/delegation.dart';
import 'package:provenance_wallet/services/models/provenance_validator.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class DelegationListItem extends StatelessWidget {
  const DelegationListItem({
    Key? key,
    required this.validator,
    required this.item,
  }) : super(key: key);

  final ProvenanceValidator validator;
  final Delegation item;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        final account = await get<AccountService>().getSelectedAccount();
        if (account == null) {
          return;
        }
        final bloc = get<StakingScreenBloc>();
        final rewards = bloc.stakingDetails.value.rewards.firstWhere(
            (element) => element.validatorAddress == validator.addressId);
        final response = await Navigator.of(context).push(
          StakingFlow(
            validator.addressId,
            account,
            item,
            rewards,
          ).route(),
        );
        if (response == true) {
          await bloc.load();
        }
      },
      child: Padding(
        padding: EdgeInsets.zero,
        child: Container(
          padding: EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: Spacing.largeX3,
                height: Spacing.largeX3,
                child: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundImage: NetworkImage(validator.imgUrl ?? ""),
                  child:
                      PwText(validator.moniker.substring(0, 1).toUpperCase()),
                ),
              ),
              HorizontalSpacer.medium(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PwText(
                    validator.moniker,
                    style: PwTextStyle.bodyBold,
                  ),
                  VerticalSpacer.xSmall(),
                  SizedBox(
                    width: 180,
                    child: PwText(
                      item.endTime != null
                          ? Strings.endTimeFormatted(item.formattedTime)
                          : Strings.displayDenomFormatted(item.displayDenom),
                      color: PwColor.neutral200,
                      style: PwTextStyle.footnote,
                      overflow: TextOverflow.fade,
                      softWrap: false,
                    ),
                  ),
                ],
              ),
              Expanded(child: Container()),
              Padding(
                padding: EdgeInsets.only(left: 16),
                child: PwIcon(
                  PwIcons.caret,
                  color: Theme.of(context).colorScheme.neutralNeutral,
                  size: 12.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

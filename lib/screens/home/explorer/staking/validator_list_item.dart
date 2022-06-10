import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_flow/staking_flow.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_flow/staking_flow_bloc.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/models/delegation.dart';
import 'package:provenance_wallet/services/models/provenance_validator.dart';
import 'package:provenance_wallet/util/get.dart';

class ValidatorListItem extends StatelessWidget {
  const ValidatorListItem({
    Key? key,
    required this.item,
  }) : super(key: key);

  final ProvenanceValidator item;
  final textDivider = " • ";
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        final account = await get<AccountService>().getSelectedAccount();
        if (account == null) {
          return;
        }
        final bloc = get<StakingFlowBloc>();
        final stakingDetails = bloc.stakingDetails.value;
        Delegation? delegation;
        try {
          delegation = stakingDetails.delegates
              .firstWhere((element) => element.sourceAddress == item.addressId);
        } finally {
          await Navigator.of(context).push(
            StakingFlow(
              item.addressId,
              account,
              delegation,
            ).route(),
          );
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
                  foregroundImage: NetworkImage(item.imgUrl ?? ""),
                  child: PwText(item.moniker.substring(0, 1).toUpperCase()),
                ),
              ),
              HorizontalSpacer.medium(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PwText(
                    item.moniker,
                    style: PwTextStyle.bodyBold,
                  ),
                  VerticalSpacer.xSmall(),
                  SizedBox(
                    width: 180,
                    child: PwText(
                      '${item.delegators} delegators$textDivider${item.commission} commission',
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

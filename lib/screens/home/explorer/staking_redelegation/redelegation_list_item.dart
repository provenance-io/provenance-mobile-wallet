import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_flow/staking_flow_bloc.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_redelegation/staking_redelegation_bloc.dart';
import 'package:provenance_wallet/services/models/provenance_validator.dart';
import 'package:provenance_wallet/util/get.dart';

class RedelegationListItem extends StatelessWidget {
  RedelegationListItem({
    Key? key,
    required this.item,
  }) : super(key: key);

  final ProvenanceValidator item;
  final textDivider = " • ";
  final StakingRedelegationBloc _bloc = get<StakingRedelegationBloc>();
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<StakingRedelegationDetails>(
      stream: _bloc.stakingRedelegationDetails,
      initialData: _bloc.stakingRedelegationDetails.value,
      builder: (context, snapshot) {
        final details = snapshot.data;

        if (null == details) {
          return Container();
        }

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (item.addressId == details.delegation.sourceAddress) {
              return;
            }
            _bloc.selectRedelegation(item);
          },
          child: Container(
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
                          child: PwText(
                              item.moniker.substring(0, 1).toUpperCase()),
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
                              color: item.status == ValidatorStatus.active
                                  ? PwColor.neutral200
                                  : PwColor.neutralNeutral,
                              style: PwTextStyle.footnote,
                              overflow: TextOverflow.fade,
                              softWrap: false,
                            ),
                          ),
                        ],
                      ),
                      Expanded(child: Container()),
                      if (item == details.toRedelegate)
                        Flexible(
                            child: Padding(
                          padding: EdgeInsets.only(left: 16),
                          child: Icon(
                            Icons.check_circle,
                            color: Theme.of(context).colorScheme.neutralNeutral,
                          ),
                        )),
                    ],
                  ),
                ),
              ),
              color: item.status == ValidatorStatus.candidate
                  ? Theme.of(context).colorScheme.neutral500
                  : item.status == ValidatorStatus.jailed
                      ? Theme.of(context).colorScheme.errorContainer
                      : Colors.transparent),
        );
      },
    );
  }
}

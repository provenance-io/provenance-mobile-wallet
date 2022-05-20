import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/home/explorer/explorer_bloc.dart';
import 'package:provenance_wallet/screens/home/explorer/staking/delegation_list_item.dart';
import 'package:provenance_wallet/util/get.dart';

class DelegationList extends StatelessWidget {
  final ExplorerBloc _bloc = get<ExplorerBloc>();
  final _scrollController = ScrollController();

  DelegationList({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<StakingDetails>(
        initialData: _bloc.stakingDetails.value,
        stream: _bloc.stakingDetails,
        builder: (context, snapshot) {
          final stakingDetails = snapshot.data;
          if (stakingDetails == null) {
            return Container();
          }
          return ListView.separated(
            padding: EdgeInsets.symmetric(
              horizontal: Spacing.xxLarge,
              vertical: 20,
            ),
            controller: _scrollController,
            itemBuilder: (context, index) {
              final item = stakingDetails.delegates[index];
              final validator = stakingDetails.validators
                  .where(
                    (element) => element.addressId == item.sourceAddress,
                  )
                  .first;

              return DelegationListItem(
                validator: validator,
                item: item,
              );
            },
            separatorBuilder: (context, index) {
              return PwListDivider();
            },
            itemCount: stakingDetails.delegates.length,
            shrinkWrap: true,
            physics: AlwaysScrollableScrollPhysics(),
          );
        });
  }
}

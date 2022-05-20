import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/home/explorer/explorer_bloc.dart';
import 'package:provenance_wallet/screens/home/explorer/staking/validator_list_item.dart';
import 'package:provenance_wallet/util/get.dart';

class ValidatorList extends StatelessWidget {
  final ExplorerBloc _bloc = get<ExplorerBloc>();
  final _scrollController = ScrollController();

  ValidatorList({
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
              final item = stakingDetails.validators[index];

              return ValidatorListItem(
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

  void _onScrollEnd() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent &&
        !_bloc.isLoadingValidators.value) {
      _bloc.isLoadingValidators();
    }
  }
}

import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_flow/staking_flow_bloc.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_flow/staking_redelegation/redelegation_list_item.dart';
import 'package:provenance_wallet/services/models/detailed_validator.dart';
import 'package:provenance_wallet/util/get.dart';

class RedelegationList extends StatefulWidget {
  const RedelegationList({
    Key? key,
    required this.validator,
  }) : super(key: key);

  final DetailedValidator validator;

  @override
  State<StatefulWidget> createState() => RedelegationListState();
}

class RedelegationListState extends State<RedelegationList> {
  final StakingFlowBloc _bloc = get<StakingFlowBloc>();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScrollEnd);
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.removeListener(_onScrollEnd);
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Stack(
        children: [
          StreamBuilder<StakingDetails>(
              initialData: _bloc.stakingDetails.value,
              stream: _bloc.stakingDetails,
              builder: (context, snapshot) {
                final stakingDetails = snapshot.data;
                if (stakingDetails == null) {
                  return Container();
                }
                return ListView.separated(
                  padding: EdgeInsets.symmetric(
                    vertical: Spacing.xLarge,
                    horizontal: Spacing.largeX3,
                  ),
                  controller: _scrollController,
                  itemBuilder: (context, index) {
                    if (stakingDetails.validators.isEmpty) {
                      return Container();
                    }
                    final item = stakingDetails.validators[index];

                    if (item.moniker == widget.validator.moniker) {
                      return Container();
                    }

                    return RedelegationListItem(
                      item: item,
                    );
                  },
                  separatorBuilder: (context, index) {
                    return PwListDivider();
                  },
                  itemCount: stakingDetails.validators.length - 1,
                  shrinkWrap: true,
                  physics: AlwaysScrollableScrollPhysics(),
                );
              }),
          StreamBuilder<bool>(
            initialData: _bloc.isLoadingValidators.value,
            stream: _bloc.isLoadingValidators,
            builder: (context, snapshot) {
              final isLoading = snapshot.data ?? false;
              if (isLoading) {
                return Positioned(
                  bottom: 0,
                  left: 0,
                  child: SizedBox(
                    height: 80,
                    width: MediaQuery.of(context).size.width,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                );
              }

              return Container();
            },
          ),
        ],
      ),
    );
  }

  void _onScrollEnd() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent &&
        !_bloc.isLoadingValidators.value) {
      _bloc.loadAdditionalValidators();
    }
  }
}

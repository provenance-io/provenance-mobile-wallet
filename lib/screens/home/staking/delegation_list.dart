import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/home/staking/delegation_list_item.dart';
import 'package:provenance_wallet/screens/home/staking/staking_screen_bloc.dart';
import 'package:provenance_wallet/util/get.dart';

class DelegationList extends StatefulWidget {
  const DelegationList({
    Key? key,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() => DelegationListState();
}

class DelegationListState extends State<DelegationList> {
  final StakingScreenBloc _bloc = get<StakingScreenBloc>();
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
                    horizontal: Spacing.xxLarge,
                    vertical: 20,
                  ),
                  controller: _scrollController,
                  itemBuilder: (context, index) {
                    if (stakingDetails.delegates.isEmpty) {
                      return Container();
                    }
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
              }),
          StreamBuilder<bool>(
            initialData: _bloc.isLoadingDelegations.value,
            stream: _bloc.isLoadingDelegations,
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
      _bloc.loadAdditionalDelegates();
    }
  }
}

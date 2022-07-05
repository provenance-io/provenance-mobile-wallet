import 'package:collection/collection.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/home/staking/staking_flow/staking_flow.dart';
import 'package:provenance_wallet/screens/home/staking/staking_list_item.dart';
import 'package:provenance_wallet/screens/home/staking/staking_screen_bloc.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class ValidatorList extends StatefulWidget {
  const ValidatorList({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => ValidatorListState();
}

class ValidatorListState extends State<ValidatorList> {
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
                padding: EdgeInsets.all(
                  Spacing.large,
                ),
                controller: _scrollController,
                itemBuilder: (context, index) {
                  if (stakingDetails.validators.isEmpty) {
                    return Container();
                  }
                  final item = stakingDetails.validators[index];

                  return StakingListItem(
                    validator: item,
                    listItemText: Strings.displayDelegatorsWithCommission(
                      item.delegators,
                      item.commission,
                    ),
                    onTouch: () async {
                      final account =
                          await get<AccountService>().getSelectedAccount();
                      if (account == null) {
                        return;
                      }

                      final delegation = stakingDetails.delegates
                          .firstWhereOrNull((element) =>
                              element.sourceAddress == item.addressId);
                      final rewards = stakingDetails.rewards.firstWhereOrNull(
                          (element) =>
                              element.validatorAddress == item.addressId);

                      final response = await Navigator.of(context).push(
                        StakingFlow(
                          item.addressId,
                          account,
                          delegation,
                          rewards,
                        ).route(),
                      );
                      if (response == true) {
                        await _bloc.load();
                      }
                    },
                  );
                },
                separatorBuilder: (context, index) {
                  return PwListDivider();
                },
                itemCount: stakingDetails.validators.length,
                shrinkWrap: true,
                physics: AlwaysScrollableScrollPhysics(),
              );
            },
          ),
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

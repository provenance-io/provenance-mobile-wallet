import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/home/staking/staking_flow/staking_flow.dart';
import 'package:provenance_wallet/screens/home/staking/staking_list_item.dart';
import 'package:provenance_wallet/screens/home/staking/staking_screen_bloc.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:provider/provider.dart';

class DelegationList extends StatefulWidget {
  const DelegationList({
    Key? key,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() => DelegationListState();
}

class DelegationListState extends State<DelegationList> {
  late final StakingScreenBloc _bloc;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _bloc = Provider.of(context);
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
    return Stack(
      children: [
        StreamBuilder<StakingDetails>(
            initialData: _bloc.stakingDetails.value,
            stream: _bloc.stakingDetails,
            builder: (context, snapshot) {
              final stakingDetails = snapshot.data;
              if (stakingDetails == null || stakingDetails.delegates.isEmpty) {
                return Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      VerticalSpacer.xLarge(),
                      PwText(
                        Strings.of(context).stakingScreenNoDelegations,
                        style: PwTextStyle.bodyBold,
                      ),
                      VerticalSpacer.xSmall(),
                      PwText(
                        Strings.of(context)
                            .stakingScreenSelectValidatorsToContinue,
                        style: PwTextStyle.footnote,
                        color: PwColor.neutral250,
                      ),
                    ],
                  ),
                );
              }
              return ListView.separated(
                padding: EdgeInsets.symmetric(
                  horizontal: Spacing.large,
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

                  return StakingListItem(
                    validator: validator,
                    listItemText: Strings.of(context).displayDelegated(
                      item.displayDenom,
                    ),
                    onTouch: () async {
                      final account =
                          await get<AccountService>().getSelectedAccount();
                      if (account == null) {
                        return;
                      }
                      final rewards = stakingDetails.rewards.firstWhere(
                          (element) =>
                              element.validatorAddress == validator.addressId);
                      final response = await Navigator.of(context).push(
                        StakingFlow(
                          validator.addressId,
                          account,
                          item,
                          rewards,
                        ).route(),
                      );
                      if (response == true) {
                        await _bloc.load();
                      } else if (response == false) {
                        Navigator.pop(context);
                        _bloc.onFlowCompletion();
                      }
                    },
                  );
                },
                separatorBuilder: (context, index) {
                  return PwListDivider(
                    color: PwColor.neutral750,
                  );
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

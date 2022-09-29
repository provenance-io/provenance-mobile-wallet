import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/home/staking/staking_details/staking_details_bloc.dart';
import 'package:provenance_wallet/screens/home/staking/staking_list_item.dart';
import 'package:provenance_wallet/screens/home/staking/staking_redelegation/staking_redelegation_bloc.dart';
import 'package:provenance_wallet/screens/home/staking/staking_screen_bloc.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:provider/provider.dart';

class StakingRedelegationList extends StatefulWidget {
  const StakingRedelegationList({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _StakingRedelegationListState();
}

class _StakingRedelegationListState extends State<StakingRedelegationList> {
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
    final bloc = Provider.of<StakingScreenBloc>(context, listen: false);
    return Column(
      children: [
        VerticalSpacer.xLarge(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            PwText(
              Strings.of(context).stakingTabAvailableToSelect,
              color: PwColor.neutralNeutral,
              style: PwTextStyle.bodyBold,
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => bloc.showMenu(context),
              child: Row(
                children: [
                  PwText(
                    Strings.of(context).stakingTabSortBy,
                    color: PwColor.neutralNeutral,
                    style: PwTextStyle.body,
                  ),
                  HorizontalSpacer.small(),
                  PwIcon(
                    PwIcons.sort,
                    color: Theme.of(context).colorScheme.neutralNeutral,
                  ),
                ],
              ),
            )
          ],
        ),
        VerticalSpacer.large(),
        Expanded(
          child: Stack(
            children: [
              StreamBuilder<StakingDetails>(
                initialData: bloc.stakingDetails.value,
                stream: bloc.stakingDetails,
                builder: (context, snapshot) {
                  final stakingDetails = snapshot.data;
                  if (stakingDetails == null) {
                    return Container();
                  }
                  return ListView.separated(
                    controller: _scrollController,
                    itemBuilder: (context, index) {
                      if (stakingDetails.validators.isEmpty) {
                        return Container();
                      }
                      final item = stakingDetails.validators[index];

                      return StakingListItem(
                        validator: item,
                        listItemText: Strings.of(context).displayDelegators(
                          item.delegators,
                          item.commission,
                        ),
                        onTouch: () async {
                          Provider.of<StakingRedelegationBloc>(context,
                                  listen: false)
                              .selectRedelegation(item);
                          Provider.of<StakingDetailsBloc>(context,
                                  listen: false)
                              .showRedelegationAmountScreen();
                        },
                      );
                    },
                    separatorBuilder: (context, index) {
                      return PwListDivider();
                    },
                    itemCount: stakingDetails.validators.length,
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                  );
                },
              ),
              StreamBuilder<bool>(
                initialData: bloc.isLoadingValidators.value,
                stream: bloc.isLoadingValidators,
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
        ),
      ],
    );
  }

  void _onScrollEnd() {
    final bloc = Provider.of<StakingScreenBloc>(context, listen: false);
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent &&
        !bloc.isLoadingValidators.value) {
      bloc.loadAdditionalValidators();
    }
  }
}

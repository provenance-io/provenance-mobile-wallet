import 'package:collection/collection.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/home/staking/staking_flow/staking_flow.dart';
import 'package:provenance_wallet/screens/home/staking/staking_list_item.dart';
import 'package:provenance_wallet/screens/home/staking/staking_screen_bloc.dart';
import 'package:provenance_wallet/services/account_service/account_service.dart';
import 'package:provenance_wallet/services/models/provenance_validator.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class ValidatorList extends StatefulWidget {
  const ValidatorList({Key? key, this.onTap}) : super(key: key);
  final Function(ProvenanceValidator)? onTap;

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
    return Column(
      children: [
        VerticalSpacer.xLarge(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            PwText(
              Strings.stakingTabAvailableToSelect,
              color: PwColor.neutralNeutral,
              style: PwTextStyle.bodyBold,
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _showMenu(context),
              child: Row(
                children: [
                  PwText(
                    Strings.stakingTabSortBy,
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
                initialData: _bloc.stakingDetails.value,
                stream: _bloc.stakingDetails,
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
                        listItemText: Strings.displayDelegatorsWithCommission(
                          item.delegators,
                          item.commission,
                        ),
                        onTouch: () async {
                          if (widget.onTap != null) {
                            widget.onTap!(item);
                            return;
                          }
                          final account =
                              await get<AccountService>().getSelectedAccount();
                          if (account == null) {
                            return;
                          }

                          final delegation = stakingDetails.delegates
                              .firstWhereOrNull((element) =>
                                  element.sourceAddress == item.addressId);
                          final rewards = stakingDetails.rewards
                              .firstWhereOrNull((element) =>
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
                          } else if (response == false) {
                            Navigator.pop(context);
                            _bloc.onFlowCompletion();
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
        ),
      ],
    );
  }

  Future<void> _showMenu(
    BuildContext context,
  ) async {
    var result = await showModalBottomSheet<ValidatorSortingState>(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            PwGreyButton(
              text: ValidatorSortingState.alphabetically.dropDownTitle,
              onPressed: () {
                Navigator.of(context).pop(ValidatorSortingState.alphabetically);
              },
            ),
            PwListDivider(),
            PwGreyButton(
              text: ValidatorSortingState.commission.dropDownTitle,
              onPressed: () {
                Navigator.of(context).pop(ValidatorSortingState.commission);
              },
            ),
            PwListDivider(),
            PwGreyButton(
              text: ValidatorSortingState.delegators.dropDownTitle,
              onPressed: () {
                Navigator.of(context).pop(ValidatorSortingState.delegators);
              },
            ),
            PwListDivider(),
            PwGreyButton(
              text: ValidatorSortingState.votingPower.dropDownTitle,
              onPressed: () {
                Navigator.of(context).pop(ValidatorSortingState.votingPower);
              },
            ),
            PwListDivider(),
            PwGreyButton(
              enabled: false,
              text: "",
              // ignore: no-empty-block
              onPressed: () {},
            ),
          ],
        );
      },
    );
    if (result != null) {
      _bloc.updateSort(result);
    }
  }

  void _onScrollEnd() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent &&
        !_bloc.isLoadingValidators.value) {
      _bloc.loadAdditionalValidators();
    }
  }
}

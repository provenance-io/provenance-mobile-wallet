import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_dropdown.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/home/explorer/explorer_bloc.dart';
import 'package:provenance_wallet/screens/home/transactions/transaction_list_item.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class StakingTab extends StatefulWidget {
  const StakingTab({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => StakingTabState();
}

class StakingTabState extends State<StakingTab> {
  final _scrollController = ScrollController();
  late ExplorerBloc _bloc;

  final textDivider = " • ";

  @override
  void initState() {
    super.initState();
    _bloc = get<ExplorerBloc>();
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
    return Container(
      color: Theme.of(context).colorScheme.neutral750,
      child: SafeArea(
        bottom: false,
        child: StreamBuilder<StakingDetails>(
          initialData: _bloc.stakingDetails.value,
          stream: _bloc.stakingDetails,
          builder: (context, snapshot) {
            final stakingDetails = snapshot.data;
            if (stakingDetails == null) {
              return Container();
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppBar(
                  primary: false,
                  backgroundColor: Theme.of(context).colorScheme.neutral750,
                  elevation: 0.0,
                  title: PwText(
                    Strings.transactionDetails,
                    style: PwTextStyle.subhead,
                  ),
                  leading: Container(),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Spacing.xxLarge,
                  ),
                  child: Column(
                    children: [
                      Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context).colorScheme.neutral250,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: Spacing.medium,
                          ),
                          child: PwDropDown<ValidatorType>(
                            initialValue: stakingDetails.selectedType,
                            items: ValidatorType.values,
                            isExpanded: true,
                            onValueChanged: (item) {
                              // Change delegates
                            },
                            builder: (item) => Row(
                              children: [
                                PwText(
                                  item.dropDownTitle,
                                  color: PwColor.neutralNeutral,
                                  style: PwTextStyle.body,
                                ),
                              ],
                            ),
                          )),
                      VerticalSpacer.medium(),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).colorScheme.neutral250,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: Spacing.medium,
                        ),
                        child: PwDropDown<ValidatorStatus>(
                          initialValue: stakingDetails.selectedStatus,
                          items: ValidatorStatus.values,
                          isExpanded: true,
                          onValueChanged: (item) {
                            // Change Validators
                          },
                          builder: (item) => Row(
                            children: [
                              PwText(
                                item.dropDownTitle,
                                color: PwColor.neutralNeutral,
                                style: PwTextStyle.body,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                VerticalSpacer.medium(),
                Expanded(
                  child: Stack(
                    children: [
                      ListView.separated(
                        padding: EdgeInsets.symmetric(
                          horizontal: Spacing.xxLarge,
                          vertical: 20,
                        ),
                        controller: _scrollController,
                        itemBuilder: (context, index) {
                          final item =
                              stakingDetails.filteredTransactions[index];

                          return TransactionListItem(
                            address: stakingDetails.address,
                            item: item,
                          );
                        },
                        separatorBuilder: (context, index) {
                          return PwListDivider();
                        },
                        itemCount: stakingDetails.filteredTransactions.length,
                        shrinkWrap: true,
                        physics: AlwaysScrollableScrollPhysics(),
                      ),
                      StreamBuilder<bool>(
                        initialData: _bloc.isLoadingTransactions.value,
                        stream: _bloc.isLoadingTransactions,
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
          },
        ),
      ),
    );
  }

  void _onScrollEnd() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent &&
        !_bloc.isLoadingTransactions.value) {
      _bloc.loadAdditionalTransactions();
    }
  }
}

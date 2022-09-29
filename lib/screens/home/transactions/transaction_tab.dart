import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_dropdown.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/home/dashboard/transactions_bloc.dart';
import 'package:provenance_wallet/screens/home/transactions/transaction_list_item.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:provider/provider.dart';

class TransactionTab extends StatefulWidget {
  const TransactionTab({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => TransactionTabState();
}

class TransactionTabState extends State<TransactionTab> {
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
    final _bloc = Provider.of<TransactionsBloc>(context);
    return Container(
      color: Theme.of(context).colorScheme.neutral750,
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              primary: false,
              backgroundColor: Theme.of(context).colorScheme.neutral750,
              elevation: 0.0,
              title: PwText(
                Strings.of(context).transactionDetails,
                style: PwTextStyle.footnote,
              ),
              leading: Container(),
            ),
            Expanded(
              child: StreamBuilder<TransactionDetails>(
                  initialData: _bloc.transactionDetails.valueOrNull,
                  stream: _bloc.transactionDetails,
                  builder: (context, snapshot) {
                    final workingIndicator = SizedBox(
                      height: 80,
                      width: MediaQuery.of(context).size.width,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );

                    final transactionDetails = snapshot.data;
                    if (transactionDetails == null) {
                      return StreamBuilder<bool>(
                        initialData: _bloc.isLoadingTransactions.valueOrNull,
                        stream: _bloc.isLoadingTransactions,
                        builder: (context, snapshot) {
                          final isLoading = snapshot.data ?? false;

                          return isLoading ? workingIndicator : Container();
                        },
                      );
                    }

                    return Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: Spacing.large,
                          ),
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .neutral250,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(4)),
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: Spacing.medium,
                                ),
                                child: PwDropDown.fromStrings(
                                  value: transactionDetails.selectedType,
                                  items: transactionDetails.types,
                                  onValueChanged: (item) {
                                    _bloc.filterTransactions(
                                      item,
                                      transactionDetails.selectedStatus,
                                    );
                                  },
                                ),
                              ),
                              VerticalSpacer.medium(),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .neutral250,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(4)),
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: Spacing.medium,
                                ),
                                child: PwDropDown.fromStrings(
                                  value: transactionDetails.selectedStatus,
                                  items: transactionDetails.statuses,
                                  onValueChanged: (item) {
                                    _bloc.filterTransactions(
                                      transactionDetails.selectedType,
                                      item,
                                    );
                                  },
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
                                  horizontal: Spacing.large,
                                  vertical: 20,
                                ),
                                controller: _scrollController,
                                itemBuilder: (context, index) {
                                  final item = transactionDetails
                                      .filteredTransactions[index];

                                  return TransactionListItem(
                                    address: transactionDetails.address,
                                    item: item,
                                  );
                                },
                                separatorBuilder: (context, index) {
                                  return PwListDivider();
                                },
                                itemCount: transactionDetails
                                    .filteredTransactions.length,
                                shrinkWrap: true,
                                physics: AlwaysScrollableScrollPhysics(),
                              ),
                              StreamBuilder<bool>(
                                initialData: _bloc.isLoadingTransactions.value,
                                stream: _bloc.isLoadingTransactions,
                                builder: (context, snapshot) {
                                  final isLoading = snapshot.data ?? false;
                                  if (isLoading) {
                                    if (transactionDetails
                                        .filteredTransactions.isEmpty) {
                                      return workingIndicator;
                                    }

                                    return Positioned(
                                      bottom: 0,
                                      left: 0,
                                      child: workingIndicator,
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
                  }),
            ),
          ],
        ),
      ),
    );
  }

  void _onScrollEnd() {
    final _bloc = Provider.of<TransactionsBloc>(context);
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent &&
        !_bloc.isLoadingTransactions.value) {
      _bloc.loadAdditionalTransactions();
    }
  }
}

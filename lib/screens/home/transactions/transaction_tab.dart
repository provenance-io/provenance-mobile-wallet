import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_dropdown.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/home/home_bloc.dart';
import 'package:provenance_wallet/screens/home/transactions/transaction_list_item.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class TransactionTab extends StatefulWidget {
  const TransactionTab({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => TransactionTabState();
}

class TransactionTabState extends State<TransactionTab> {
  final _scrollController = ScrollController();
  late HomeBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = get<HomeBloc>();
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
        child: StreamBuilder<TransactionDetails>(
          initialData: _bloc.transactionDetails.value,
          stream: _bloc.transactionDetails,
          builder: (context, snapshot) {
            final transactionDetails = snapshot.data;
            if (transactionDetails == null) {
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
                    Strings.of(context).transactionDetails,
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
                            color: Theme.of(context).colorScheme.neutral250,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(4)),
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
                          horizontal: Spacing.xxLarge,
                          vertical: 20,
                        ),
                        controller: _scrollController,
                        itemBuilder: (context, index) {
                          final item =
                              transactionDetails.filteredTransactions[index];

                          return TransactionListItem(
                            address: transactionDetails.address,
                            item: item,
                          );
                        },
                        separatorBuilder: (context, index) {
                          return PwListDivider();
                        },
                        itemCount:
                            transactionDetails.filteredTransactions.length,
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

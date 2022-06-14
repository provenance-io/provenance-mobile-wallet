import 'package:collection/collection.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/home/explorer/proposals/proposals_bloc.dart';
import 'package:provenance_wallet/screens/home/explorer/proposals/proposals_list_item.dart';
import 'package:provenance_wallet/util/get.dart';

class ProposalsList extends StatefulWidget {
  const ProposalsList({
    Key? key,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() => ProposalsListState();
}

class ProposalsListState extends State<ProposalsList> {
  final ProposalsBloc _bloc = get<ProposalsBloc>();
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
          StreamBuilder<ProposalDetails>(
              initialData: _bloc.proposalDetails.value,
              stream: _bloc.proposalDetails,
              builder: (context, snapshot) {
                final details = snapshot.data;
                if (details == null) {
                  return Container();
                }
                return ListView.separated(
                  padding: EdgeInsets.symmetric(
                    horizontal: Spacing.xxLarge,
                    vertical: 20,
                  ),
                  controller: _scrollController,
                  itemBuilder: (context, index) {
                    if (details.proposals.isEmpty) {
                      return Container();
                    }
                    final item = details.proposals[index];
                    final vote = details.myVotes.firstWhereOrNull(
                      (element) => element.proposalId == item.proposalId,
                    );

                    return ProposalListItem(
                      item: item,
                      vote: vote,
                    );
                  },
                  separatorBuilder: (context, index) {
                    return PwListDivider();
                  },
                  itemCount: details.proposals.length,
                  shrinkWrap: true,
                  physics: AlwaysScrollableScrollPhysics(),
                );
              }),
          StreamBuilder<bool>(
            initialData: _bloc.isLoadingProposals.value,
            stream: _bloc.isLoadingProposals,
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
        !_bloc.isLoadingProposals.value) {
      _bloc.loadAdditionalProposals();
    }
  }
}

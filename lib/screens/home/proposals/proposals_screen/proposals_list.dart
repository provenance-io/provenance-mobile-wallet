import 'package:collection/collection.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/home/proposals/proposals_screen/proposals_bloc.dart';
import 'package:provenance_wallet/screens/home/proposals/proposals_screen/proposals_list_item.dart';
import 'package:provider/provider.dart';

class ProposalsList extends StatefulWidget {
  const ProposalsList({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => ProposalsListState();
}

class ProposalsListState extends State<ProposalsList> {
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
    final bloc = Provider.of<ProposalsBloc>(context);
    return Expanded(
      child: RefreshIndicator(
        onRefresh: () async {
          await bloc.load(
            showLoading: false,
          );
        },
        color: Theme.of(context).colorScheme.indicatorActive,
        child: Stack(
          children: [
            StreamBuilder<ProposalDetails>(
                initialData: bloc.proposalDetails.value,
                stream: bloc.proposalDetails,
                builder: (context, snapshot) {
                  final details = snapshot.data;
                  if (details == null) {
                    return Container();
                  }
                  return ListView.separated(
                    padding: EdgeInsets.symmetric(
                      horizontal: Spacing.large,
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
              initialData: bloc.isLoadingProposals.value,
              stream: bloc.isLoadingProposals,
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
    );
  }

  void _onScrollEnd() {
    final bloc = Provider.of<ProposalsBloc>(context, listen: false);
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent &&
        !bloc.isLoadingProposals.value) {
      bloc.loadAdditionalProposals();
    }
  }
}

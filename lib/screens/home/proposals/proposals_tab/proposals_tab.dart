import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/screens/home/proposals/proposals_tab/proposals_bloc.dart';
import 'package:provenance_wallet/screens/home/proposals/proposals_tab/proposals_list.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class ProposalsTab extends StatefulWidget {
  const ProposalsTab({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => ProposalsTabState();
}

class ProposalsTabState extends State<ProposalsTab> {
  late ProposalsBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = get<ProposalsBloc>();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: [
          Container(
            color: Theme.of(context).colorScheme.neutral750,
            child: SafeArea(
              bottom: false,
              child: StreamBuilder<ProposalDetails>(
                initialData: _bloc.proposalDetails.value,
                stream: _bloc.proposalDetails,
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
                        backgroundColor:
                            Theme.of(context).colorScheme.neutral750,
                        elevation: 0.0,
                        title: PwText(
                          Strings.proposalsTabProposals,
                          style: PwTextStyle.subhead,
                        ),
                        leading: IconButton(
                          icon: PwIcon(
                            PwIcons.back,
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                      ProposalsList(),
                    ],
                  );
                },
              ),
            ),
          ),
          StreamBuilder<bool>(
            initialData: _bloc.isLoading.value,
            stream: _bloc.isLoading,
            builder: (context, snapshot) {
              final isLoading = snapshot.data ?? false;
              if (isLoading) {
                return SizedBox(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: Center(
                    child: CircularProgressIndicator(),
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
}

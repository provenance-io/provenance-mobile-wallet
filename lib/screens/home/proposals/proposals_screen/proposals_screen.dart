import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/screens/home/proposals/proposals_screen/proposals_bloc.dart';
import 'package:provenance_wallet/screens/home/proposals/proposals_screen/proposals_legend.dart';
import 'package:provenance_wallet/screens/home/proposals/proposals_screen/proposals_list.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:provider/provider.dart';

class ProposalsScreen extends StatefulWidget {
  const ProposalsScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ProposalsScreenState();
}

class _ProposalsScreenState extends State<ProposalsScreen> {
  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<ProposalsBloc>(context);
    return Material(
      child: Stack(
        children: [
          Container(
            color: Theme.of(context).colorScheme.neutral750,
            child: SafeArea(
              bottom: false,
              child: StreamBuilder<ProposalDetails>(
                initialData: bloc.proposalDetails.value,
                stream: bloc.proposalDetails,
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
                          Strings.of(context).governanceProposals,
                          style: PwTextStyle.footnote,
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
                      ProposalsLegend(),
                      ProposalsList(),
                    ],
                  );
                },
              ),
            ),
          ),
          StreamBuilder<bool>(
            initialData: bloc.isLoading.value,
            stream: bloc.isLoading,
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

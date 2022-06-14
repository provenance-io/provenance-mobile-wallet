import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_details/staking_details_bloc.dart';
import 'package:provenance_wallet/screens/home/transactions/details_item.dart';
import 'package:provenance_wallet/services/models/proposal.dart';
import 'package:provenance_wallet/util/strings.dart';

class ProposalDetailsScreen extends StatefulWidget {
  const ProposalDetailsScreen({
    Key? key,
    required this.selectedProposal,
  }) : super(key: key);

  final Proposal selectedProposal;

  @override
  State<StatefulWidget> createState() => _ProposalDetailsScreenState();
}

class _ProposalDetailsScreenState extends State<ProposalDetailsScreen> {
  // @override
  // void initState() {
  //   get.registerSingleton<StakingDetailsBloc>(_bloc);
  //   super.initState();
  // }

  // @override
  // void dispose() {
  //   get.unregister<StakingDetailsBloc>();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: Theme.of(context).colorScheme.neutral750,
          child: StreamBuilder<DetailedValidatorDetails>(
            initialData: _bloc.validatorDetails.value,
            stream: _bloc.validatorDetails,
            builder: (context, snapshot) {
              final details = snapshot.data;
              final validator = snapshot.data?.validator;
              final commission = snapshot.data?.commission;
              if (details == null || validator == null || commission == null) {
                return Container();
              }

              return Scaffold(
                appBar: PwAppBar(
                  title: "Proposal ${widget.selectedProposal.proposalId}",
                  leadingIcon: PwIcons.back,
                ),
                body: ListView(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: Spacing.largeX3,
                        vertical: Spacing.xLarge,
                      ),
                      child: PwText(
                        "Proposal Information",
                        style: PwTextStyle.title,
                      ),
                    ),
                    PwListDivider(
                      indent: Spacing.largeX3,
                    ),
                    DetailsItem(
                      title: "ID",
                      endChild: PwText("${widget.selectedProposal.proposalId}"),
                    ),
                    PwListDivider(
                      indent: Spacing.largeX3,
                    ),
                    DetailsItem(
                      title: "Title",
                      endChild: PwText(widget.selectedProposal.title),
                    ),
                    PwListDivider(
                      indent: Spacing.largeX3,
                    ),
                    DetailsItem(
                      title: "Status",
                      endChild: PwText(widget.selectedProposal.status),
                    ),
                    PwListDivider(
                      indent: Spacing.largeX3,
                    ),
                    DetailsItem(
                      title: "Proposer",
                      endChild: PwText(widget.selectedProposal.proposerAddress
                          .abbreviateAddress()),
                    ),
                    PwListDivider(
                      indent: Spacing.largeX3,
                    ),
                    DetailsItem(
                      title: "Description",
                      endChild: PwText(widget.selectedProposal.description),
                    ),
                    PwListDivider(
                      indent: Spacing.largeX3,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: Spacing.largeX3,
                        vertical: Spacing.xLarge,
                      ),
                      child: PwText(
                        "Proposal Timing",
                        style: PwTextStyle.title,
                      ),
                    ),
                    PwListDivider(
                      indent: Spacing.largeX3,
                    ),
                  ],
                ),
              );
            },
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
    );
  }
}

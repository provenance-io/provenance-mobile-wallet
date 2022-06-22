import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/button.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/home/explorer/proposals_flow/proposal_weighted_vote/weighted_vote_bloc.dart';
import 'package:provenance_wallet/screens/home/explorer/proposals_flow/proposal_weighted_vote/weighted_voting_pie_chart.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_flow/staking_delegation/staking_text_form_field.dart';
import 'package:provenance_wallet/screens/home/transactions/details_item.dart';
import 'package:provenance_wallet/services/models/proposal.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class ProposalWeightedVoteScreen extends StatefulWidget {
  const ProposalWeightedVoteScreen({
    Key? key,
    required this.proposal,
  }) : super(key: key);

  final Proposal proposal;

  @override
  State<StatefulWidget> createState() => _ProposalDetailsScreenState();
}

class _ProposalDetailsScreenState extends State<ProposalWeightedVoteScreen> {
  late final WeightedVoteBloc _bloc;
  late final TextEditingController _yesTextEditingController;
  late final TextEditingController _noTextEditingController;
  late final TextEditingController _noWithVetoTextEditingController;
  late final TextEditingController _abstainTextEditingController;

  @override
  void initState() {
    _bloc = WeightedVoteBloc();
    get.registerSingleton<WeightedVoteBloc>(_bloc);
    _yesTextEditingController = TextEditingController(text: "100");
    _noTextEditingController = TextEditingController(text: "0");
    _noWithVetoTextEditingController = TextEditingController(text: "0");
    _abstainTextEditingController = TextEditingController(text: "0");
    _yesTextEditingController.addListener(_onYesTextChanged);
    _noTextEditingController.addListener(_onNoTextChanged);
    _noWithVetoTextEditingController.addListener(_onNoWithVetoTextChanged);
    _abstainTextEditingController.addListener(_onAbstainTextChanged);

    super.initState();
  }

  @override
  void dispose() {
    get.unregister<WeightedVoteBloc>();
    _yesTextEditingController.removeListener(_onYesTextChanged);
    _noTextEditingController.removeListener(_onNoTextChanged);
    _noWithVetoTextEditingController.removeListener(_onNoWithVetoTextChanged);
    _abstainTextEditingController.removeListener(_onAbstainTextChanged);
    _yesTextEditingController.dispose();
    _noTextEditingController.dispose();
    _noWithVetoTextEditingController.dispose();
    _abstainTextEditingController.dispose();
    super.dispose();
  }

  void _onYesTextChanged() {
    _bloc.updateWeight(
      yesAmount: double.tryParse(_yesTextEditingController.text),
    );
  }

  void _onNoTextChanged() {
    _bloc.updateWeight(
      noAmount: double.tryParse(_noTextEditingController.text),
    );
  }

  void _onNoWithVetoTextChanged() {
    _bloc.updateWeight(
      noWithVetoAmount: double.tryParse(_noWithVetoTextEditingController.text),
    );
  }

  void _onAbstainTextChanged() {
    _bloc.updateWeight(
      abstainAmount: double.tryParse(_abstainTextEditingController.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PwAppBar(
        title: Strings.proposalWeightedVote,
        leadingIcon: PwIcons.back,
      ),
      body: Container(
        color: Theme.of(context).colorScheme.neutral750,
        child: ListView(
          children: [
            DetailsItem(
              title: Strings.proposalDetailsYes,
              endChild: Flexible(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: StakingTextFormField(
                        hint: "",
                        textEditingController: _yesTextEditingController,
                      ),
                    ),
                    PwText(" %"),
                  ],
                ),
              ),
            ),
            PwListDivider(
              indent: Spacing.largeX3,
            ),
            DetailsItem(
              title: Strings.proposalDetailsNo,
              endChild: Flexible(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: StakingTextFormField(
                        hint: "",
                        textEditingController: _noTextEditingController,
                      ),
                    ),
                    PwText(" %"),
                  ],
                ),
              ),
            ),
            PwListDivider(
              indent: Spacing.largeX3,
            ),
            DetailsItem(
              title: Strings.proposalDetailsNoWithVeto,
              endChild: Flexible(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: StakingTextFormField(
                        hint: "",
                        textEditingController: _noWithVetoTextEditingController,
                      ),
                    ),
                    PwText(" %"),
                  ],
                ),
              ),
            ),
            PwListDivider(
              indent: Spacing.largeX3,
            ),
            DetailsItem(
              title: Strings.proposalDetailsAbstain,
              endChild: Flexible(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: StakingTextFormField(
                        hint: "",
                        textEditingController: _abstainTextEditingController,
                      ),
                    ),
                    PwText(" %"),
                  ],
                ),
              ),
            ),
            PwListDivider(
              indent: Spacing.largeX3,
            ),
            WeightedVotingPieChart(
              yes: Theme.of(context).colorScheme.primary550,
              no: Theme.of(context).colorScheme.error,
              noWithVeto: Theme.of(context).colorScheme.notice350,
              abstain: Theme.of(context).colorScheme.neutral600,
            ),
            StreamBuilder<WeightedVoteDetails>(
              initialData: _bloc.weightedVoteDetails.value,
              stream: _bloc.weightedVoteDetails,
              builder: (context, snapshot) {
                final details = snapshot.data;

                if (details == null) {
                  return Container();
                }
                return Padding(
                  padding: EdgeInsets.only(
                    left: Spacing.largeX3,
                    right: Spacing.largeX3,
                    bottom: Spacing.largeX3,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: PwButton(
                          enabled: details.abstainAmount +
                                  details.noAmount +
                                  details.noWithVetoAmount +
                                  details.yesAmount ==
                              100,
                          onPressed: () {
                            // TODO: Submit weighted vote.
                          },
                          child: PwText(
                            Strings.continueName,
                            overflow: TextOverflow.fade,
                            softWrap: false,
                            color: PwColor.neutralNeutral,
                            style: PwTextStyle.body,
                          ),
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
import 'package:provenance_wallet/common/widgets/pw_list_divider.dart';
import 'package:provenance_wallet/screens/home/explorer/proposals_flow/proposal_weighted_vote/weighted_vote_bloc.dart';
import 'package:provenance_wallet/screens/home/explorer/proposals_flow/proposal_weighted_vote/weighted_voting_pie_chart.dart';
import 'package:provenance_wallet/screens/home/explorer/staking_flow/staking_delegation/staking_text_form_field.dart';
import 'package:provenance_wallet/screens/home/transactions/details_item.dart';
import 'package:provenance_wallet/services/models/proposal.dart';
import 'package:provenance_wallet/util/get.dart';

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
    _yesTextEditingController = TextEditingController();
    _noTextEditingController = TextEditingController();
    _noWithVetoTextEditingController = TextEditingController();
    _abstainTextEditingController = TextEditingController();
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
        yesAmount: double.tryParse(_yesTextEditingController.text));
  }

  void _onNoTextChanged() {
    _bloc.updateWeight(
        noAmount: double.tryParse(_noTextEditingController.text));
  }

  void _onNoWithVetoTextChanged() {
    _bloc.updateWeight(
        noWithVetoAmount:
            double.tryParse(_noWithVetoTextEditingController.text));
  }

  void _onAbstainTextChanged() {
    _bloc.updateWeight(
        abstainAmount: double.tryParse(_abstainTextEditingController.text));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.neutral750,
      child: Scaffold(
        appBar: PwAppBar(
          title: "Weighted Vote",
          leadingIcon: PwIcons.back,
        ),
        body: ListView(
          children: [
            DetailsItem(
              title: "Yes",
              endChild: StakingTextFormField(
                hint: "%",
                textEditingController: _yesTextEditingController,
              ),
            ),
            PwListDivider(
              indent: Spacing.largeX3,
            ),
            DetailsItem(
              title: "No",
              endChild: StakingTextFormField(
                hint: "%",
                textEditingController: _noTextEditingController,
              ),
            ),
            PwListDivider(
              indent: Spacing.largeX3,
            ),
            DetailsItem(
              title: "No With Veto",
              endChild: StakingTextFormField(
                hint: "%",
                textEditingController: _noWithVetoTextEditingController,
              ),
            ),
            PwListDivider(
              indent: Spacing.largeX3,
            ),
            DetailsItem(
              title: "Abstain",
              endChild: StakingTextFormField(
                hint: "%",
                textEditingController: _abstainTextEditingController,
              ),
            ),
            PwListDivider(
              indent: Spacing.largeX3,
            ),
            WeightedVotingPieChart(),
          ],
        ),
      ),
    );
  }
}

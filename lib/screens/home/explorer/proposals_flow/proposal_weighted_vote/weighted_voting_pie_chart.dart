import 'package:fl_chart/fl_chart.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/screens/home/explorer/proposals_flow/proposal_weighted_vote/weighted_vote_bloc.dart';
import 'package:provenance_wallet/util/get.dart';

class WeightedVotingPieChart extends StatefulWidget {
  const WeightedVotingPieChart({
    Key? key,
    required this.yes,
    required this.no,
    required this.noWithVeto,
    required this.abstain,
  }) : super(key: key);

  final Color yes;
  final Color no;
  final Color noWithVeto;
  final Color abstain;

  @override
  State<StatefulWidget> createState() => _WeightedVotingPieChartState();
}

class _WeightedVotingPieChartState extends State<WeightedVotingPieChart> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = get<WeightedVoteBloc>();

    return StreamBuilder<WeightedVoteDetails>(
      initialData: bloc.weightedVoteDetails.value,
      stream: bloc.weightedVoteDetails,
      builder: (context, snapshot) {
        final details = snapshot.data;

        if (details == null) {
          return Container();
        }
        final style = Theme.of(context).textTheme.displayBody;

        return AspectRatio(
          aspectRatio: 1.3,
          child: PieChart(
            PieChartData(
              startDegreeOffset: 180,
              borderData: FlBorderData(
                show: false,
              ),
              sectionsSpace: 1,
              centerSpaceRadius: 0,
              sections: [
                PieChartSectionData(
                  title: "Yes",
                  color: widget.yes,
                  value: details.yesAmount,
                  titleStyle: style,
                ),
                PieChartSectionData(
                  title: "No",
                  color: widget.no,
                  value: details.noAmount,
                  titleStyle: style,
                ),
                PieChartSectionData(
                  title: "No With Veto",
                  color: widget.noWithVeto,
                  value: details.noWithVetoAmount,
                  titleStyle: style,
                ),
                PieChartSectionData(
                  title: "Abstain",
                  color: widget.abstain,
                  value: details.abstainAmount,
                  titleStyle: style,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

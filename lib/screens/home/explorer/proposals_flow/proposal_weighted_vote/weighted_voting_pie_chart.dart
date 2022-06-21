import 'package:fl_chart/fl_chart.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/screens/home/explorer/proposals_flow/proposal_weighted_vote/weighted_vote_bloc.dart';
import 'package:provenance_wallet/util/get.dart';

class WeightedVotingPieChart extends StatefulWidget {
  const WeightedVotingPieChart({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _WeightedVotingPieChartState();
}

class _WeightedVotingPieChartState extends State<WeightedVotingPieChart> {
  int touchedIndex = -1;
  late final Color _yes;
  late final Color _no;
  late final Color _noWithVeto;
  late final Color _abstain;

  @override
  void initState() {
    final colorScheme = Theme.of(context).colorScheme;
    _yes = colorScheme.primary550;
    _no = colorScheme.error;
    _noWithVeto = colorScheme.notice350;
    _abstain = colorScheme.neutral600;
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

        return AspectRatio(
          aspectRatio: 1.3,
          child: Card(
            color: Colors.white,
            child: Column(
              children: <Widget>[
                const SizedBox(
                  height: 28,
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Indicator(
                      color: _yes,
                      text: 'Yes',
                      isSquare: false,
                      size: touchedIndex == 0 ? 18 : 16,
                      textColor: touchedIndex == 0 ? Colors.black : Colors.grey,
                    ),
                    Indicator(
                      color: _no,
                      text: 'No',
                      isSquare: false,
                      size: touchedIndex == 1 ? 18 : 16,
                      textColor: touchedIndex == 1 ? Colors.black : Colors.grey,
                    ),
                    Indicator(
                      color: _noWithVeto,
                      text: 'No With Veto',
                      isSquare: false,
                      size: touchedIndex == 2 ? 18 : 16,
                      textColor: touchedIndex == 2 ? Colors.black : Colors.grey,
                    ),
                    Indicator(
                      color: _abstain,
                      text: 'Abstain',
                      isSquare: false,
                      size: touchedIndex == 3 ? 18 : 16,
                      textColor: touchedIndex == 3 ? Colors.black : Colors.grey,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 18,
                ),
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: PieChart(
                      PieChartData(
                          pieTouchData: PieTouchData(touchCallback:
                              (FlTouchEvent event, pieTouchResponse) {
                            setState(() {
                              if (!event.isInterestedForInteractions ||
                                  pieTouchResponse == null ||
                                  pieTouchResponse.touchedSection == null) {
                                touchedIndex = -1;
                                return;
                              }
                              touchedIndex = pieTouchResponse
                                  .touchedSection!.touchedSectionIndex;
                            });
                          }),
                          startDegreeOffset: 180,
                          borderData: FlBorderData(
                            show: false,
                          ),
                          sectionsSpace: 1,
                          centerSpaceRadius: 0,
                          sections: showingSections(details)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<PieChartSectionData> showingSections(
    WeightedVoteDetails details,
  ) {
    return List.generate(
      4,
      (i) {
        final isTouched = i == touchedIndex;
        final opacity = isTouched ? 1.0 : 0.6;

        switch (i) {
          case 0:
            return PieChartSectionData(
              color: _yes.withOpacity(opacity),
              value: details.yesAmount ?? 25,
              title: '',
              radius: 80,
              titleStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff044d7c)),
              titlePositionPercentageOffset: 0.55,
              borderSide: isTouched
                  ? BorderSide(color: _yes.darken(40), width: 6)
                  : BorderSide(color: _no.withOpacity(0)),
            );
          case 1:
            return PieChartSectionData(
              color: _no.withOpacity(opacity),
              value: details.noAmount ?? 25,
              title: '',
              radius: 65,
              titleStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff90672d)),
              titlePositionPercentageOffset: 0.55,
              borderSide: isTouched
                  ? BorderSide(color: _no.darken(40), width: 6)
                  : BorderSide(color: _noWithVeto.withOpacity(0)),
            );
          case 2:
            return PieChartSectionData(
              color: _noWithVeto.withOpacity(opacity),
              value: details.noWithVetoAmount ?? 25,
              title: '',
              radius: 60,
              titleStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff4c3788)),
              titlePositionPercentageOffset: 0.6,
              borderSide: isTouched
                  ? BorderSide(color: _noWithVeto.darken(40), width: 6)
                  : BorderSide(color: _noWithVeto.withOpacity(0)),
            );
          case 3:
            return PieChartSectionData(
              color: _abstain.withOpacity(opacity),
              value: details.abstainAmount ?? 25,
              title: '',
              radius: 70,
              titleStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff0c7f55)),
              titlePositionPercentageOffset: 0.55,
              borderSide: isTouched
                  ? BorderSide(color: _abstain.darken(40), width: 6)
                  : BorderSide(color: _noWithVeto.withOpacity(0)),
            );
          default:
            throw Error();
        }
      },
    );
  }
}

class Indicator extends StatelessWidget {
  final Color color;
  final String text;
  final bool isSquare;
  final double size;
  final Color textColor;

  const Indicator({
    Key? key,
    required this.color,
    required this.text,
    required this.isSquare,
    this.size = 16,
    this.textColor = const Color(0xff505050),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(
          width: 4,
        ),
        Text(
          text,
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
        )
      ],
    );
  }
}

extension ColorExtension on Color {
  /// Convert the color to a darken color based on the [percent]
  Color darken([int percent = 40]) {
    assert(1 <= percent && percent <= 100);
    final value = 1 - percent / 100;
    return Color.fromARGB(alpha, (red * value).round(), (green * value).round(),
        (blue * value).round());
  }
}

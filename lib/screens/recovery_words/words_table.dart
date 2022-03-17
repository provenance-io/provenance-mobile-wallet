import 'package:provenance_wallet/common/pw_design.dart';

class WordsTable extends StatelessWidget {
  const WordsTable({Key? key, required this.words})
      : assert(words.length == 24),
        super(key: key);

  final List<String> words;

  @override
  Widget build(BuildContext context) {
    return Table(
      children: [
        WordRow(
          index1: 0,
          word1: words[0],
          index2: 12,
          word2: words[12],
        ),
        WordRow(
          index1: 1,
          word1: words[1],
          index2: 13,
          word2: words[13],
        ),
        WordRow(
          index1: 2,
          word1: words[2],
          index2: 14,
          word2: words[14],
        ),
        WordRow(
          index1: 3,
          word1: words[3],
          index2: 15,
          word2: words[15],
        ),
        WordRow(
          index1: 4,
          word1: words[4],
          index2: 16,
          word2: words[16],
        ),
        WordRow(
          index1: 5,
          word1: words[5],
          index2: 17,
          word2: words[17],
        ),
        WordRow(
          index1: 6,
          word1: words[6],
          index2: 18,
          word2: words[18],
        ),
        WordRow(
          index1: 7,
          word1: words[7],
          index2: 19,
          word2: words[19],
        ),
        WordRow(
          index1: 8,
          word1: words[8],
          index2: 20,
          word2: words[20],
        ),
        WordRow(
          index1: 9,
          word1: words[9],
          index2: 21,
          word2: words[21],
        ),
        WordRow(
          index1: 10,
          word1: words[10],
          index2: 22,
          word2: words[22],
        ),
        WordRow(
          index1: 11,
          word1: words[11],
          index2: 23,
          word2: words[23],
        ),
      ],
    );
  }
}

class WordRow extends TableRow {
  const WordRow({
    LocalKey? key,
    required this.index1,
    required this.word1,
    required this.index2,
    required this.word2,
  }) : super(key: key);

  final int index1;
  final String word1;
  final int index2;
  final String word2;

  @override
  List<Widget>? get children => [
        Column(children: [
          WordCell(
            index: index1,
            word: word1,
          ),
          VerticalSpacer.small(),
        ]),
        Column(children: [
          WordCell(
            index: index2,
            word: word2,
          ),
          VerticalSpacer.small(),
        ]),
      ];
}

class WordCell extends StatelessWidget {
  const WordCell({
    Key? key,
    required this.index,
    required this.word,
  }) : super(key: key);

  final int index;
  final String word;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 122,
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.only(
              right: Spacing.small,
            ),
            child: PwText(
              '${index + 1}',
              style: PwTextStyle.body,
              color: PwColor.neutral250,
            ),
          ),
          PwText(
            word,
            style: PwTextStyle.body,
          ),
        ],
      ),
    );
  }
}

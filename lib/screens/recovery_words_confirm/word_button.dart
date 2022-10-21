import 'package:provenance_wallet/common/pw_design.dart';

class WordButton extends StatelessWidget {
  const WordButton({
    required this.groupIndex,
    required this.word,
    required this.isSelected,
    required this.setSelected,
    Key? key,
  }) : super(key: key);

  final int groupIndex;
  final String word;
  final bool isSelected;
  final Function setSelected;

  static ValueKey keyWordButton(String word, int index) =>
      ValueKey("$WordButton.word_$word.$index");

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;

    return Flexible(
      child: GestureDetector(
        key: WordButton.keyWordButton(word, groupIndex),
        child: Container(
          height: 42,
          decoration: BoxDecoration(
            color:
                isSelected ? colorScheme.secondary700 : colorScheme.neutral700,
            borderRadius: BorderRadius.all(Radius.circular(4.0)),
            border: Border.all(
              color: isSelected
                  ? colorScheme.secondary400
                  : colorScheme.neutral700,
            ),
          ),
          child: Center(
            child: PwText(
              word,
              color: PwColor.neutralNeutral,
              style: PwTextStyle.bodyBold,
            ),
          ),
        ),
        onTap: () {
          setSelected();
        },
      ),
    );
  }
}

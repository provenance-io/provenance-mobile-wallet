import 'package:provenance_wallet/common/pw_design.dart';

class WordButton extends StatelessWidget {
  const WordButton({
    required this.word,
    required this.isSelected,
    required this.setSelected,
    Key? key,
  }) : super(key: key);

  final String word;
  final bool isSelected;
  final Function setSelected;

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;

    return Flexible(
      child: GestureDetector(
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

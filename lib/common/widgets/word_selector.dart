import 'package:flutter_tech_wallet/common/fw_design.dart';

typedef OnWordSelected(String word);

class WordSelector extends StatefulWidget {
  WordSelector({
    @required this.words,
    @required this.wordNumber,
    @required this.onWordSelected,
  });

  final List<String>? words;
  final int? wordNumber;
  final OnWordSelected? onWordSelected;

  @override
  State<StatefulWidget> createState() {
    return WordSelectorState();
  }
}

class WordSelectorState extends State<WordSelector> {
  String? selectedWord;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FwText(
          'Select word #${widget.wordNumber}',
          style: FwTextStyle.m,
        ),
        SizedBox(
          height: 8,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: widget.words
                  ?.map((e) => GestureDetector(
                        child: Container(
                          height: 44,
                          width: 108,
                          decoration: BoxDecoration(
                            color: e == selectedWord
                                ? Theme.of(context)
                                    .colorScheme
                                    .globalNeutral600Black
                                : Theme.of(context)
                                    .colorScheme
                                    .globalNeutral350,
                            borderRadius:
                                BorderRadius.all(Radius.circular(22.0)),
                          ),
                          child: Center(
                            child: FwText(
                              e,
                              color: FwColor.white,
                            ),
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            selectedWord = e;
                            widget.onWordSelected?.call(e);
                          });
                        },
                      ))
                  .toList() ??
              [],
        ),
      ],
    );
  }
}

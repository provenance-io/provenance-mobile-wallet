import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/screens/recovery_words_confirm/recovery_words_bloc.dart';
import 'package:provenance_wallet/screens/recovery_words_confirm/word_button.dart';
import 'package:provenance_wallet/util/get.dart';
import 'package:provenance_wallet/util/strings.dart';

class WordSelector extends StatefulWidget {
  WordSelector({
    required this.index,
  });

  final int index;

  @override
  State<StatefulWidget> createState() {
    return WordSelectorState();
  }
}

class WordSelectorState extends State<WordSelector> {
  String? selectedWord;

  @override
  Widget build(BuildContext context) {
    final bloc = get<RecoveryWordsBloc>();

    return Padding(
      padding: EdgeInsets.only(left: Spacing.xxLarge, right: Spacing.xxLarge),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          StreamBuilder<List<int?>>(
            initialData: bloc.trueWordsIndex.value,
            stream: bloc.trueWordsIndex,
            builder: (context, snapshot) {
              final trueWordIndex = snapshot.data?[widget.index];

              return PwText(
                (trueWordIndex == null || trueWordIndex == -1)
                    ? Strings.selectWord
                    : Strings.selectWordIndex('${trueWordIndex + 1}'),
                style: PwTextStyle.body,
              );
            },
          ),
          VerticalSpacer.large(),
          StreamBuilder<List<List<String>>>(
            initialData: bloc.wordGroups.value,
            stream: bloc.wordGroups,
            builder: (context, snapshot) {
              final words = snapshot.data?[widget.index] ?? [];
              final colorScheme = Theme.of(context).colorScheme;

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: words
                    .map((e) => WordButton(
                          word: e,
                          isSelected: e == selectedWord,
                          setSelected: () {
                            setState(() {
                              selectedWord = e;
                              bloc.wordSelected(e, widget.index);
                            });
                          },
                        ))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

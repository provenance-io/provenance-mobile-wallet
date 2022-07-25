import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/screens/recovery_words_confirm/recovery_words_bloc.dart';
import 'package:provenance_wallet/screens/recovery_words_confirm/word_button.dart';
import 'package:provenance_wallet/util/strings.dart';

class WordSelector extends StatefulWidget {
  const WordSelector({
    required this.bloc,
    required this.index,
    Key? key,
  }) : super(key: key);

  final RecoveryWordsBloc bloc;
  final int index;

  @override
  State<StatefulWidget> createState() {
    return WordSelectorState();
  }
}

class WordSelectorState extends State<WordSelector> {
  @override
  Widget build(BuildContext context) {
    final bloc = widget.bloc;

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
                    ? Strings.of(context).selectWord
                    : Strings.of(context).selectWordIndex(trueWordIndex + 1),
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
              final selectedWord = bloc.selectedWords.value[widget.index];

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: words
                    .map((e) {
                      return [
                        WordButton(
                          word: e,
                          isSelected: e == selectedWord,
                          setSelected: () {
                            setState(() {
                              bloc.wordSelected(e, widget.index);
                            });
                          },
                        ),
                        HorizontalSpacer.small(),
                      ];
                    })
                    .expand((element) => element)
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

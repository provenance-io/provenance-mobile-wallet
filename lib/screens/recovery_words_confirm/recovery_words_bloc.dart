import 'dart:async';
import 'dart:math';

import 'package:rxdart/rxdart.dart';
import 'package:get_it/get_it.dart';

class RecoveryWordsBloc extends Disposable {
  final _random = new Random();
  final BehaviorSubject<List<String?>> _selectedWords = BehaviorSubject.seeded([
    null,
    null,
    null,
    null,
  ]);
  final BehaviorSubject<List<int?>> _trueWordsIndex = BehaviorSubject.seeded([
    null,
    null,
    null,
    null,
  ]);
  final BehaviorSubject<List<List<String>>> _wordGroups =
      BehaviorSubject.seeded([]);
  final BehaviorSubject<List<String>> _trueWords = BehaviorSubject.seeded([]);

  ValueStream<List<String?>> get selectedWords => _selectedWords.stream;
  ValueStream<List<int?>> get trueWordsIndex => _trueWordsIndex.stream;
  ValueStream<List<List<String>>> get wordGroups => _wordGroups.stream;
  ValueStream<List<String>> get trueWords => _trueWords.stream;

  void setup(List<String>? words) {
    List<String>? localWords = words?.toList(growable: true);

    for (var i = 0; i < 4; i++) {
      var index = _next(0, (localWords?.length ?? 2) - 1);
      var trueWord = localWords?.removeAt(index) ?? "";
      var trueWordIndex = words?.indexOf(trueWord);
      _trueWordsIndex.value[i] = trueWordIndex;
      _trueWords.value.add(trueWord);
      var wordGroup = _getWordList(localWords, trueWord);
      wordGroup.shuffle();
      _wordGroups.value.add(wordGroup);
    }
  }

  void wordSelected(String word, int index) {
    _selectedWords.value[index] = word;
  }

  @override
  FutureOr onDispose() {
    _selectedWords.close();
    _trueWordsIndex.close();
    _wordGroups.close();
    _trueWords.close();
  }

  int _next(
    int min,
    int max,
  ) {
    return min + _random.nextInt(max - min);
  }

  List<String> _getWordList(List<String>? words, String includedWord) {
    List<String> selectedWords = [includedWord];
    for (var i = 0; i < 2; i++) {
      selectedWords.add(words?[_next(0, words.length)] ?? "");
    }

    return selectedWords;
  }
}

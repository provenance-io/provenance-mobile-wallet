import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:provenance_dart/wallet.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:rxdart/rxdart.dart';

class RecoverPassphraseBloc extends Disposable {
  RecoverPassphraseBloc() {
    for (var i = 0; i < _wordsCount; i++) {
      var word = TextEditingController();
      _addListener(word, i);
      textControllers.add(word);
      focusNodes.add(FocusNode());
      _stringLists.add(BehaviorSubject.seeded([]));
    }
  }
  static const _wordsCount = 24;
  List<TextEditingController> textControllers = <TextEditingController>[];
  List<FocusNode> focusNodes = <FocusNode>[];
  List<VoidCallback> callbacks = <VoidCallback>[];

  final List<BehaviorSubject<List<String>>> _stringLists =
      <BehaviorSubject<List<String>>>[];

  @override
  FutureOr onDispose() {
    for (var i = 0; i < _wordsCount; i++) {
      var controller = textControllers[i];
      var callback = callbacks[i];
      _stringLists[i].close();
      controller.removeListener(callback);
      controller.dispose();
    }
  }

  TextEditingController getControllerFromIndex(int index) {
    return textControllers[index];
  }

  FocusNode getFocusNodeFromIndex(int index) {
    return focusNodes[index];
  }

  Stream<List<String>> getWordsForIndex(int index) {
    return _stringLists[index].stream;
  }

  void changeWordsForIndex(List<String> words, int index) {
    clearWordsForIndex(index);
    _stringLists[index].value = words;
  }

  void clearWordsForIndex(int index) {
    _stringLists[index].value.clear();
  }

  bool isMnemonicComplete() {
    return textControllers.every((e) => e.text.isNotEmpty);
  }

  List<String> getCompletedMnemonic() {
    return textControllers.map((e) => e.text.trim()).toList();
  }

  void _addListener(TextEditingController controller, int index) {
    void listen() {
      _handleTextControllerTextChange(index);
    }

    controller.addListener(listen);
    callbacks.add(listen);
  }

  _handleTextControllerTextChange(int index) {
    final controller = textControllers[index];
    String pastedText = controller.text;
    changeWordsForIndex(Mnemonic.searchFor(pastedText).toList(), index);
    if (pastedText.isNotEmpty) {
      //ist<String> parts = pastedText.split(' ');
      // ignore: unnecessary_string_escapes
      var mnemonic =
          RegExp(r'(?<=\d+|\b)([a-zA-Z]+)(?=\d+|\b)', multiLine: true);
      var parts =
          mnemonic.allMatches(pastedText).map((e) => e.group(1) ?? "").toList();
      if (parts.length == 48) {
        parts.removeWhere((element) => element.startsWith("[0-9]"));
      }
      if (parts.length == 24) {
        _putPartsInText(parts);
      }
    }
  }

  _putPartsInText(List<String> parts) {
    for (var i = 0; i < parts.length && i < textControllers.length; i++) {
      textControllers[i].text = parts[i];
    }
  }
}

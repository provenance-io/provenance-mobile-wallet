import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:provenance_wallet/common/pw_design.dart';

class RecoverPassphraseBloc extends Disposable {
  final wordsCount = 24;
  Map<int, TextEditingController> textControllers = {};
  List<VoidCallback> callbacks = <VoidCallback>[];

  @override
  FutureOr onDispose() {
    for (var i = 0; i < wordsCount; i++) {
      var controller = textControllers[i];
      var callback = callbacks[i];
      controller?.removeListener(callback);
      controller?.dispose();
    }
  }

  void setFromIndex(int index, TextEditingController controller) {
    if (textControllers[index] == controller) {
      return;
    } else {
      textControllers[index] = controller;
      _addListener(controller, index);
    }
  }

  List<String> getCompletedMnemonic() {
    return textControllers.entries.map((e) => e.value.text.trim()).toList();
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
    String pastedText = controller?.text ?? "";
    if (pastedText.isNotEmpty) {
      // ignore: unnecessary_string_escapes
      var mnemonic =
          RegExp(r'(?<=\d+|\b)([a-zA-Z]+)(?=\d+|\b)', multiLine: true);
      var parts =
          mnemonic.allMatches(pastedText).map((e) => e.group(1) ?? "").toList();
      if (parts.length == wordsCount) {
        _putPartsInText(parts);
      }
    }
  }

  _putPartsInText(List<String> parts) {
    for (var i = 0; i < parts.length && i < textControllers.length; i++) {
      textControllers[i]?.text = parts[i];
    }
  }
}

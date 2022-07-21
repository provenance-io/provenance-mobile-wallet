import 'package:flutter/foundation.dart';

mixin ListenableMixin on Listenable {
  final List<VoidCallback> _listeners = <VoidCallback>[];

  @override
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void notifyListeners() {
    final copy = List.from(_listeners);
    for (final callback in copy) {
      callback();
    }
  }
}

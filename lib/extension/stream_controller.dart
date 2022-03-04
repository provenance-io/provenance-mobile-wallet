import 'dart:async';

extension StreamControllerExtension<T> on StreamController<T> {
  void tryAdd(T item) {
    if (!isClosed) {
      add(item);
    }
  }
}

import 'dart:collection';

extension IterableExtensions<T> on Iterable<T> {
  Iterable<T> distinctBy(Object Function(T e) getCompareValue) {
    var result = <T>[];
    for (var element in this) {
      if (!result.any((x) => getCompareValue(x) == getCompareValue(element))) {
        result.add(element);
      }
    }

    return result;
  }

  T? elementAtOrNull(int index) {
    T? value;

    if (this is List || this is Queue) {
      if (length > index) {
        value = elementAt(index);
      }
    } else {
      var i = 0;
      for (var element in this) {
        if (index == i) {
          value = element;
          break;
        }

        i++;
      }
    }

    return value;
  }
}

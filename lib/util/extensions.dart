import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension MaterialPageExt<T> on Widget {
  MaterialPage<T> page({
    LocalKey? key,
    String? name,
    bool fullScreenDialog = false,
  }) =>
      MaterialPage(
        key: key ?? ValueKey('$runtimeType'),
        child: this,
        name: name,
        fullscreenDialog: fullScreenDialog,
      );

  MaterialPageRoute<T> route() => MaterialPageRoute<T>(builder: (_) => this);
}

extension DoubleExt on double {
  String toCurrency({showCents = true}) =>
      NumberFormat.simpleCurrency(decimalDigits: showCents ? null : 0)
          .format(this);

  int toCoinAmount() => (this * 100).round();
}

extension IterableExtension<T> on Iterable<T> {
  Iterable<T> distinctBy(Object Function(T e) getCompareValue) {
    var result = <T>[];
    for (var element in this) {
      if (!result.any((x) => getCompareValue(x) == getCompareValue(element))) {
        result.add(element);
      }
    }

    return result;
  }
}

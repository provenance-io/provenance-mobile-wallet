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

  MaterialPageRoute<T> route() => MaterialPageRoute(builder: (_) => this);
}

extension DoubleExt on double {
  String toCurrency({showCents = true}) =>
      NumberFormat.simpleCurrency(decimalDigits: showCents ? null : 0)
          .format(this);

  int toCoinAmount() => (this * 100).round();
}

import 'package:flutter/material.dart';

extension MaterialPageExtensions<T> on Widget {
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

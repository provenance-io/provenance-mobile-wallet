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

  MaterialPageRoute<T> route({
    bool fullScreenDialog = false,
  }) =>
      MaterialPageRoute<T>(
        builder: (_) => this,
        fullscreenDialog: fullScreenDialog,
      );
}

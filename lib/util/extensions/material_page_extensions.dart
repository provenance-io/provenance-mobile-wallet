import 'package:flutter/material.dart';

extension MaterialPageExtensions on Widget {
  MaterialPage<T> page<T>({
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

  MaterialPageRoute<T> route<T>({
    bool fullScreenDialog = false,
  }) =>
      MaterialPageRoute<T>(
        builder: (_) => this,
        fullscreenDialog: fullScreenDialog,
      );
}

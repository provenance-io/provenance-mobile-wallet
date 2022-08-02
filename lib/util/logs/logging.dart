import 'dart:convert';
import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';

extension LogExtension on Object {
  void log(dynamic message) => Log.instance.info(message, tag: '$runtimeType');

  void logDebug(dynamic message) =>
      Log.instance.debug(message, tag: '$runtimeType');

  void logError(
    dynamic message, {
    Object? error,
    StackTrace? stackTrace,
  }) =>
      Log.instance.error(
        message,
        tag: '$runtimeType',
        error: error,
        stack: stackTrace,
      );
}

class Log {
  static final instance = Log();

  static const _encoder = JsonEncoder.withIndent(kDebugMode ? '   ' : null);

  static const _white = '\x1B[37m';
  static const _blue = '\x1B[34m';
  static const _red = '\x1B[31m';
  static const _reset = '\x1B[0m';

  void debug(
    dynamic message, {
    required String tag,
  }) {
    final messageStr = _stringifyMessage(message);

    dev.log(
      '$_white[$tag] [d] $messageStr$_reset',
    );
  }

  void info(
    dynamic message, {
    required String tag,
  }) {
    final messageStr = _stringifyMessage(message);

    dev.log(
      '$_blue[$tag] [i] $messageStr$_reset',
    );
  }

  void error(
    dynamic message, {
    required String tag,
    Object? error,
    StackTrace? stack,
  }) {
    var stackTrace = stack;

    if (stackTrace == null && error is Error) {
      stackTrace = error.stackTrace;
    }
    final messageStr = _stringifyMessage(message);

    dev.log(
      '$_red[$tag] [e] $messageStr$_reset',
      error: error,
      stackTrace: stackTrace,
    );
  }

  String _stringifyMessage(dynamic message) {
    if (message is String) {
      return message;
    }

    return message is Map || message is Iterable
        ? _encoder.convert(message)
        : message.toString();
  }
}

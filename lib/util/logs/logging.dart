import 'dart:convert';
import 'dart:developer' as dev;

import 'package:logger/logger.dart';
import 'package:provenance_wallet/services/crash_reporting/crash_reporting_service.dart';
import 'package:provenance_wallet/util/get.dart';

export 'package:logger/logger.dart';

final _log = _Logger(
  printer: _SimpleScopedPrinter(
    printTime: true,
    prettyJson: false, // set to true as needed for development
  ),
  output: _Output(),
  filter: _LogFilter(),
);

/// Extension on Object to use `runtimeType`
extension Log on Object {
  void log(dynamic message) => _log.info(message, tag: '$runtimeType');

  void logDebug(dynamic message) => _log.debug(message, tag: '$runtimeType');

  void logError(
    dynamic message, {
    dynamic error,
    StackTrace? stackTrace,
  }) =>
      _log.error(
        message,
        tag: '$runtimeType',
        error: error,
        stackTrace: stackTrace,
      );
}

/// For calling from static methods
void logStatic(
  String tag,
  Level level,
  dynamic message, {
  dynamic error,
}) {
  if (level == Level.error) {
    _log.error(
      message,
      tag: tag,
      error: error,
    );
  } else if (level == Level.debug) {
    _log.debug(message, tag: tag);
  } else {
    _log.info(message, tag: tag);
  }
}

class _Logger extends Logger {
  _Logger({
    required LogPrinter printer,
    LogOutput? output,
    LogFilter? filter,
  }) : super(
          printer: printer,
          output: output,
          filter: filter,
        );

  void info(
    dynamic message, {
    required String tag,
  }) =>
      log(
        Level.info,
        [tag, message],
        null,
        null,
      );

  void debug(
    dynamic message, {
    required String tag,
  }) =>
      _log.log(
        Level.debug,
        [tag, message],
        null,
        null,
      );

  void error(
    dynamic message, {
    required String tag,
    dynamic error,
    StackTrace? stackTrace,
  }) =>
      _log.log(
        Level.error,
        [tag, message],
        error,
        stackTrace,
      );
}

class _SimpleScopedPrinter extends SimplePrinter {
  _SimpleScopedPrinter({bool printTime = true, bool prettyJson = false})
      : _encoder = JsonEncoder.withIndent(prettyJson ? '   ' : null),
        super(printTime: printTime);

  /// If `prettyJson`, a `Map` or `Iterable` will be indented
  final JsonEncoder _encoder;

  /// Adding emoji prefixes for visual cues because intellij doesn't support
  /// ANSI escape codes for non Java based projects yet
  static final levelPrefixes = {
    Level.verbose: '[v]',
    Level.debug: '[d]',
    Level.info: '[i]',
    Level.warning: '🟡',
    Level.error: '🔴',
    Level.wtf: '🆘',
  };

  @override
  List<String> log(LogEvent event) {
    var map = event.message as List<dynamic>;
    var scope = map[0];
    var messageStr = _stringifyMessage(map[1]);
    var errorStr = event.error != null ? '  ERROR: ${event.error}' : '';
    var timeStr = printTime ? '[${DateTime.now().toIso8601String()}]' : '';

    return [
      scope,
      timeStr,
      '${_labelFor(event.level)} $messageStr$errorStr',
    ];
  }

  String _labelFor(Level level) {
    return levelPrefixes[level]!;
  }

  String _stringifyMessage(dynamic message) {
    return message is Map || message is Iterable
        ? _encoder.convert(message)
        : message.toString();
  }
}

class _Output extends LogOutput {
  @override
  void output(OutputEvent event) {
    dev.log('${event.lines[1]} ${event.lines[2]}', name: event.lines[0]);

    if (event.level != Level.debug) {
      if (get.isRegistered<CrashReportingService>()) {
        // no need to add time
        get<CrashReportingService>()
            .log('[${event.lines[0]}] ${event.lines[2]}');
      }
    }
  }
}

class _LogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    return true; // log everything
  }
}

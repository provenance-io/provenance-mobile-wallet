import 'package:flutter/foundation.dart';
import 'package:provenance_wallet/services/crash_reporting/crash_reporting_service.dart';

class LoggingCrashReportingService implements CrashReportingService {
  bool _collectionEnabled = true;

  @override
  Future<void> deleteUnsentReports() => Future.value();

  @override
  Future<void> enableCrashCollection({
    required bool enable,
  }) async {
    _collectionEnabled = enable;
  }

  @override
  Future<void> log(String message) async {
    if (!_collectionEnabled) return;

    log(message);
  }

  @override
  Future<void> recordError(exception, {StackTrace? stack}) async {
    if (!_collectionEnabled) return;

    log('Error reported: $exception');

    if (stack != null) {
      log(stack.toString());
    }
  }

  @override
  Future<void> recordFlutterError(
    FlutterErrorDetails flutterErrorDetails, {
    bool fatal = false,
  }) async {
    if (!_collectionEnabled) return;

    final exception = flutterErrorDetails.exception;
    final stack = flutterErrorDetails.stack;

    log('Flutter error reported: $exception');

    if (stack != null) {
      log(stack.toString());
    }
  }
}

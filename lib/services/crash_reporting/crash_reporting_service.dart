import 'package:flutter/foundation.dart';

abstract class CrashReportingService {
  Future<void> log(String message);

  Future<void> recordError(
    dynamic exception, {
    StackTrace? stack,
  });

  Future<void> recordFlutterError(
    FlutterErrorDetails flutterErrorDetails, {
    bool fatal = false,
  });

  Future<void> enableCrashCollection({
    required bool enable,
  });

  Future<void> deleteUnsentReports();
}

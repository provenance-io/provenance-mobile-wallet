import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:provenance_wallet/services/crash_reporting/crash_reporting_client.dart';

class FirebaseCrashReportingClient implements CrashReportingClient {
  static final _instance = FirebaseCrashlytics.instance;

  @override
  Future<void> log(String message) => _instance.log(message);

  @override
  Future<void> recordFlutterError(
    FlutterErrorDetails flutterErrorDetails, {
    bool fatal = false,
  }) =>
      _instance.recordFlutterError(
        flutterErrorDetails,
        fatal: fatal,
      );

  @override
  Future<void> deleteUnsentReports() => _instance.deleteUnsentReports();

  @override
  Future<void> enableCrashCollection({required bool enable}) =>
      _instance.setCrashlyticsCollectionEnabled(enable);

  @override
  Future<void> recordError(
    dynamic exception, {
    StackTrace? stack,
  }) =>
      _instance.recordError(exception, stack);
}

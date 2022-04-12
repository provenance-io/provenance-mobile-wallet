import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:provenance_wallet/services/crash_reporting/crash_reporting_service.dart';

class FirebaseCrashReportingService implements CrashReportingService {
  @override
  Future<void> log(String message) => FirebaseCrashlytics.instance.log(message);
}

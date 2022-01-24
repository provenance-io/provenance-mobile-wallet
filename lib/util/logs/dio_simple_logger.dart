import 'package:dio/dio.dart';
import 'package:provenance_wallet/util/logs/logging.dart';

class SimpleLogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    log('Request [${options.method}] => ${options.uri}');

    // debug level - do not send to Crashlytics
    if (options.data != null) logDebug(options.data);

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    log('Response [${response.statusCode}] => ${response.requestOptions.uri}');

    // debug level - do not send to Crashlytics
    if (response.data != null) logDebug(response.data);

    super.onResponse(response, handler);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    logError(
      'Error [${err.response?.statusCode}] => ${err.requestOptions.uri}',
      error: err.error,
    );

    // debug level - do not send to Crashlytics
    if (err.response?.data != null) logDebug(err.response!.data);

    super.onError(err, handler);
  }
}

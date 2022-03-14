import 'package:dio/dio.dart';

class HttpClientDiagnosticInterceptor extends Interceptor {
  HttpClientDiagnosticInterceptor(this.statusCode);

  final int statusCode;

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final error = Response(
      data: response.data,
      headers: response.headers,
      requestOptions: response.requestOptions,
      isRedirect: response.isRedirect,
      statusCode: statusCode,
      redirects: response.redirects,
      extra: response.extra,
    );

    throw DioError(
      requestOptions: response.requestOptions,
      response: error,
    );
  }
}

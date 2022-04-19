import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:provenance_wallet/services/http_client_diagnostic_interceptor.dart';
import 'package:provenance_wallet/services/models/base_response.dart';
import 'package:provenance_wallet/util/logs/dio_simple_logger.dart';
import 'package:provenance_wallet/util/logs/logging.dart';

const String httpHeaderAccept = 'Accept';
const String httpHeaderContentType = 'content-type';
const String httpHeaderAuth = 'Authorization';

const String contentTypeJson =
    'application/json;application/json;charset=UTF-8';
const String contentTypeMultiPart = 'multipart/form-data';

typedef SessionTimeoutCallback = void Function(bool hasJwt);

class MainHttpClient extends HttpClient {
  MainHttpClient({
    required String baseUrl,
  }) : super(
          baseUrl: baseUrl,
        );
}

class TestHttpClient extends HttpClient {
  TestHttpClient({
    required String baseUrl,
  }) : super(
          baseUrl: baseUrl,
        );
}

class HttpClient {
  HttpClient({
    required String baseUrl,
  }) : _baseUrl = baseUrl {
    _initDio();
  }

  final String _baseUrl;
  String _organizationUuid = '';
  String _jwtToken = '';
  Interceptor? _diagosticsInterceptor;
  late Dio _dio;

  SessionTimeoutCallback? onTimeout;

  bool get hasJwt => jwtToken.isNotEmpty;

  String get jwtToken => _jwtToken;

  Map<String, String> get headers {
    if (_jwtToken.isNotEmpty) {
      return {httpHeaderAuth: _jwtToken};
    }

    return {};
  }

  getOrganizationUuid() {
    return _organizationUuid;
  }

  setOrganizationUuid(String uuid) {
    _organizationUuid = uuid;
  }

  setJwt(String jwt) {
    _jwtToken = jwt;
    _initDio();
  }

  setJwtTokenWithoutInit(String jwt) {
    _jwtToken = jwt;
  }

  ///
  /// Force the client to throw an error on all requests
  /// for diagnostic purposes.
  ///
  setDiagnosticsError(int? statusCode) {
    if (statusCode != null) {
      final interceptor = HttpClientDiagnosticInterceptor(statusCode);
      _diagosticsInterceptor = interceptor;
      _dio.interceptors.add(interceptor);
    } else {
      _dio.interceptors.remove(_diagosticsInterceptor);
    }
  }

  signOut() {
    setJwt('');
    _initDio();
  }

  Future<BaseResponse<T>> downloadDocument<T>(
    dynamic path, {
    Map<String, dynamic>? additionalHeaders,
    Map<String, dynamic>? queryStringParameters,
    T Function(Map<String, dynamic> json)? converter,
    T Function(List<dynamic> json)? listConverter,
  }) async {
    //add additional headers
    if (additionalHeaders != null) {
      _dio.options.headers.addAll(additionalHeaders);
    }

    try {
      final res = await _dio.get(
        path,
        queryParameters: queryStringParameters,
        options: Options(responseType: ResponseType.bytes),
      );
      if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
        final map = res.data as Map<String, dynamic>;
        if (map['errors'] != null && map.length == 1) {
          var error = '';
          error = map['errors'] is List<dynamic>
              ? (map['errors'] as List<String>).first
              : map['errors'];

          return BaseResponse<T>.error(
            DioError(
              error: error,
              requestOptions: RequestOptions(path: path),
            ),
            ignore403: true,
            errorMessage: error,
          );
        }
      }

      return BaseResponse<T>(
        res,
        converter == null ? null : (json) => converter(json),
        listConverter == null ? null : (json) => listConverter(json),
        setJwt: setJwt,
      );
    } on DioError catch (e) {
      return BaseResponse<T>.error(e);
    }
  }

  Future<BaseResponse<T>> get<T>(
    path, {
    T Function(Map<String, dynamic> json)? converter,
    T Function(List<dynamic> json)? listConverter,
    Map<String, dynamic>? additionalHeaders,
    Map<String, dynamic>? queryStringParameters,
    ResponseType responseType = ResponseType.json,
    bool documentDownload = false,
    bool ignore403 = false,
  }) async {
    if (documentDownload) {
      return downloadDocument(
        path,
        additionalHeaders: additionalHeaders,
        converter: converter,
        listConverter: listConverter,
        queryStringParameters: queryStringParameters,
      );
    }

    //add additional headers
    if (additionalHeaders != null) {
      _dio.options.headers.addAll(additionalHeaders);
    }

    _dio.options.responseType = responseType;

    try {
      Response res = await _dio.get(
        path,
        queryParameters: queryStringParameters,
      );
      if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
        final map = res.data as Map<String, dynamic>;
        if (map['errors'] != null && map.length == 1) {
          String error = '';
          error = map['errors'] is List<dynamic>
              ? (map['errors'] as List<String>).first
              : map['errors'];

          return BaseResponse<T>.error(
            DioError(
              error: error,
              requestOptions: RequestOptions(path: path),
            ),
            ignore403: true,
            errorMessage: error,
          );
        }
      }

      return BaseResponse<T>(
        res,
        converter == null ? null : (json) => converter(json),
        listConverter == null ? null : (json) => listConverter(json),
        setJwt: setJwt,
      );
    } on DioError catch (e) {
      logError('error parsing');

      return BaseResponse<T>.error(
        e,
        ignore403: ignore403,
      );
    } catch (e) {
      logError('error parsing');

      return BaseResponse<T>.error(
        DioError(
          type: DioErrorType.other,
          requestOptions: RequestOptions(path: path),
          error: e.toString(),
        ),
        ignore403: ignore403,
      );
    }
  }

  Future<BaseResponse<T>> delete<T>(
    path, {
    T Function(Map<String, dynamic> json)? converter,
    T Function(List<dynamic> json)? listConverter,
    Map<String, dynamic>? additionalHeaders,
    Map<String, dynamic>? queryStringParameters,
    dynamic body,
  }) async {
    //add additional headers
    if (additionalHeaders != null) {
      _dio.options.headers.addAll(additionalHeaders);
    }

    try {
      Response res = await _dio.delete(
        path,
        queryParameters: queryStringParameters,
        data: json.encode(body),
      );
      if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
        final map = res.data as Map<String, dynamic>;
        if (map['errors'] != null && map.length == 1) {
          String error = '';
          error = map['errors'] is List<dynamic>
              ? (map['errors'] as List<String>).first
              : map['errors'];

          return BaseResponse<T>.error(
            DioError(
              error: error,
              requestOptions: RequestOptions(path: path),
            ),
            ignore403: true,
            errorMessage: error,
          );
        }
      }

      return BaseResponse<T>(
        res,
        converter == null ? null : (json) => converter(json),
        listConverter == null ? null : (json) => listConverter(json),
        setJwt: setJwt,
      );
    } on DioError catch (e) {
      logError('error parsing');

      return BaseResponse<T>.error(e);
    } catch (e) {
      logError('error parsing');

      return BaseResponse<T>.error(DioError(
        type: DioErrorType.other,
        requestOptions: RequestOptions(path: path),
        error: e.toString(),
      ));
    }
  }

  Future<BaseResponse<T>> post<T>(
    dynamic path, {
    T Function(Map<String, dynamic> json)? converter,
    T Function(List<dynamic> json)? listConverter,
    Map<String, dynamic>? additionalHeaders,
    dynamic body,
    Map<String, String>? queryStringParameters,
    ResponseType responseType = ResponseType.json,
    Encoding? encoding,
  }) async {
    if (additionalHeaders != null) {
      _dio.options.headers.addAll({httpHeaderContentType: contentTypeJson});
      _dio.options.headers.addAll(additionalHeaders);
    }

    _dio.options.responseType = responseType;

    try {
      Response res = await _dio.post(
        path,
        data: json.encode(body),
        queryParameters: queryStringParameters,
      );

      if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
        final map = res.data as Map<String, dynamic>;
        if (map['errors'] != null && map.length == 1) {
          String error = '';
          error = map['errors'] is List<dynamic>
              ? (map['errors'] as List<String>).first
              : map['errors'];

          return BaseResponse<T>.error(
            DioError(
              error: error,
              requestOptions: RequestOptions(path: path),
            ),
            ignore403: true,
            errorMessage: error,
          );
        }
      }

      return BaseResponse<T>(
        res,
        converter == null ? null : (json) => converter(json),
        listConverter == null ? null : (json) => listConverter(json),
        setJwt: setJwt,
      );
    } on DioError catch (e) {
      if (e.response?.statusCode == 400 &&
          e.response?.data is Map<String, dynamic>) {
        final map = e.response?.data as Map<String, dynamic>;
        if (map['errors'] != null && map.length == 1) {
          String error = '';
          error = map['errors'] is List<dynamic>
              ? (map['errors'] as List<dynamic>).first
              : map['errors'];

          return BaseResponse<T>.error(
            DioError(
              error: error,
              requestOptions: RequestOptions(path: path),
            ),
            ignore403: true,
            errorMessage: error,
          );
        }
      }

      return BaseResponse<T>.error(e);
    }
  }

  Future<BaseResponse<T>> patch<T>(
    dynamic path, {
    T Function(Map<String, dynamic> json)? converter,
    T Function(List<dynamic> json)? listConverter,
    Map<String, dynamic>? additionalHeaders,
    dynamic body,
    Map<String, String>? queryStringParameters,
    Encoding? encoding,
  }) async {
    if (additionalHeaders != null) {
      _dio.options.headers.addAll({httpHeaderContentType: contentTypeJson});
      _dio.options.headers.addAll(additionalHeaders);
    }

    try {
      Response res = await _dio.patch(
        path,
        data: json.encode(body),
        queryParameters: queryStringParameters,
      );
      if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
        final map = res.data as Map<String, dynamic>;
        if (map['errors'] != null && map.length == 1) {
          String error = '';
          error = map['errors'] is List<dynamic>
              ? (map['errors'] as List<String>).first
              : map['errors'];

          return BaseResponse<T>.error(
            DioError(
              error: error,
              requestOptions: RequestOptions(path: path),
            ),
            ignore403: true,
            errorMessage: error,
          );
        }
      }

      return BaseResponse<T>(
        res,
        converter == null ? null : (json) => converter(json),
        listConverter == null ? null : (json) => listConverter(json),
        setJwt: setJwt,
      );
    } on DioError catch (e) {
      return BaseResponse<T>.error(e);
    } on Error catch (e) {
      return BaseResponse<T>.error(
        DioError(
          error: e,
          requestOptions: RequestOptions(path: path),
        ),
      );
    } catch (e) {
      return BaseResponse<T>.error(DioError(
        type: DioErrorType.other,
        requestOptions: RequestOptions(path: path),
        error: e.toString(),
      ));
    }
  }

  Future<BaseResponse<T>> put<T>(
    dynamic path, {
    T Function(Map<String, dynamic> json)? converter,
    T Function(List<dynamic> json)? listConverter,
    Map<String, dynamic>? additionalHeaders,
    dynamic body,
    Map<String, String>? queryStringParameters,
    Encoding? encoding,
  }) async {
    if (additionalHeaders != null) {
      _dio.options.headers.addAll({httpHeaderContentType: contentTypeJson});
      _dio.options.headers.addAll(additionalHeaders);
    }

    try {
      Response res = await _dio.put(
        path,
        data: json.encode(body),
        queryParameters: queryStringParameters,
      );
      if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
        final map = res.data as Map<String, dynamic>;
        if (map['errors'] != null && map.length == 1) {
          String error = '';
          error = map['errors'] is List<dynamic>
              ? (map['errors'] as List<String>).first
              : map['errors'];

          return BaseResponse<T>.error(
            DioError(
              error: error,
              requestOptions: RequestOptions(path: path),
            ),
            ignore403: true,
            errorMessage: error,
          );
        }
      }

      return BaseResponse<T>(
        res,
        converter == null ? null : (json) => converter(json),
        listConverter == null ? null : (json) => listConverter(json),
        setJwt: setJwt,
      );
    } on DioError catch (e) {
      return BaseResponse<T>.error(e);
    } catch (e) {
      return BaseResponse<T>.error(DioError(
        type: DioErrorType.other,
        requestOptions: RequestOptions(path: path),
        error: e.toString(),
      ));
    }
  }

  Future<BaseResponse<T>> formPostWithData<T>(
    dynamic path, {
    T Function(Map<String, dynamic> json)? converter,
    T Function(List<dynamic> json)? listConverter,
    Map<String, dynamic>? additionalHeaders,
    dynamic body,
    ProgressCallback? progressCallback,
    Encoding? encoding,
  }) async {
    Options additionalOptions = Options();
    additionalOptions.headers
        ?.addAll({httpHeaderContentType: contentTypeMultiPart});

    if (additionalHeaders != null) {
      _dio.options.headers.addAll(additionalHeaders);
    }

    FormData formData = FormData.fromMap({
      'type': body['type'],
    });

    formData.files.add(MapEntry(
      'file',
      MultipartFile.fromBytes(
        body['file'],
        filename: 'file',
      ),
    ));

    if (body['uuid'] != null) {
      formData.fields.add(MapEntry(
        'uuid',
        body['uuid'],
      ));
    }

    try {
      Response res = await _dio.post(
        path,
        options: additionalOptions,
        data: formData,
        onSendProgress: (count, total) {
          if (progressCallback != null) {
            progressCallback(count, total);
          }
        },
      );
      if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
        final map = res.data as Map<String, dynamic>;
        if (map['errors'] != null && map.length == 1) {
          String error = '';
          error = map['errors'] is List<dynamic>
              ? (map['errors'] as List<String>).first
              : map['errors'];

          return BaseResponse<T>.error(
            DioError(
              error: error,
              requestOptions: RequestOptions(path: path),
            ),
            ignore403: true,
            errorMessage: error,
          );
        }
      }

      return BaseResponse<T>(
        res,
        converter == null ? null : (json) => converter(json),
        listConverter == null ? null : (json) => listConverter(json),
        setJwt: setJwt,
      );
    } on DioError catch (e) {
      return BaseResponse<T>.error(e);
    }
  }

  Future<dynamic> formPost(
    dynamic path, {
    Map<String, dynamic>? additionalHeaders,
    dynamic body,
    Encoding? encoding,
  }) async {
    Options additionalOptions = Options();
    if (additionalHeaders != null) {
      additionalOptions.headers
          ?.addAll({httpHeaderContentType: contentTypeMultiPart});
      _dio.options.headers.addAll(additionalHeaders);
    }

    FormData formData = FormData.fromMap({
      'uuid': body.invoiceUuid,
      'type': body.type,
    });

    formData.files.add(
      MapEntry('file', MultipartFile.fromBytes(body.file, filename: 'file')),
    );

    Response response;
    //upload a video
    response = await _dio
        .post(
      path,
      options: additionalOptions,
      data: formData,
    )
        .catchError((error) {
      logError('formPost()', error: error);

      return (error?.response != null) ? error.response : {};
    });
//    if (response.statusCode == 200 && response.data is Map<dynamic, dynamic>) {
//      final map = response.data as Map<String, String>;
//      if (map["errors"] != null && map.length == 1) {
//        String error = "";
//        if (map["errors"] is List<dynamic>) {
//          error = (map["errors"] as List<String>).first;
//        } else {
//          error = map["errors"];
//        }
//        return BaseResponse<T>.error(DioError(error: error), ignore403: true);
//      }
//    }

    return response.data;
  }

  _initDio() {
    BaseOptions options = BaseOptions(
      receiveTimeout: 60000,
      connectTimeout: 60000,
    );
    options.responseType = ResponseType.json;

    _dio = Dio(options);

    // If you want to use a proxy like charles, uncomment below ⬇
    //  String proxy = Platform.isAndroid ? '<localip>:8888' : 'localhost:8888';
    //  (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client) {
    //    // Hook into the findProxy callback to set the client's proxy.
    //    client.findProxy = (url) {
    //    return 'PROXY $proxy';
    //    };
    //    client.badCertificateCallback = (X509Certificate cert, String host, int port) => Platform.isAndroid;
    //  };

    _dio.interceptors.removeWhere((i) {
      return true;
    });

    _dio.options.responseType = ResponseType.json;
    _dio.options.baseUrl = _baseUrl;
    _dio.interceptors.add(InterceptorsWrapper(onRequest:
        (RequestOptions options, RequestInterceptorHandler handler) async {
      if (options.responseType != ResponseType.bytes) {
        options.headers[httpHeaderAccept] = contentTypeJson;
      }
      if (options.headers[httpHeaderContentType] == null &&
          options.headers[httpHeaderContentType] != contentTypeMultiPart) {
        options.headers[httpHeaderContentType] = contentTypeJson;
      }
      if (_jwtToken.isNotEmpty) {
        options.headers[httpHeaderAuth] = _jwtToken;
      }
      if (_organizationUuid.isNotEmpty) {
        options.headers['x-org-uuid'] = _organizationUuid;
      }

      return handler.next(options);
    }));

    _dio.interceptors.add(SimpleLogInterceptor());

    // Uncomment to get more detailed request/response info
    //   if (!_isProd) {
    //     _dio.interceptors.add(LogInterceptor(
    //       request: true,
    //       requestHeader: true,
    //       requestBody: false,
    //       responseHeader: false,
    //       responseBody: false,
    //       error: true,
    //     ));
    //   }
  }
}

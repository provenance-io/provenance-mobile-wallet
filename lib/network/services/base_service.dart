import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_tech_wallet/util/logs/dio_simple_logger.dart';
import 'package:flutter_tech_wallet/util/logs/logging.dart';

const String ACCEPT = 'Accept';
const String CONTENT_TYPE = 'content-type';
const String JSON = 'application/json;application/json;charset=UTF-8';
const String MULTI_PART = 'multipart/form-data';
const String AUTH = 'Authorization';
const String IMPERSONATE = 'x-impersonate';

typedef void SessionTimeoutCallback(bool hasJwt);

abstract class FigureSerializable {
  fromJson();
}

class BaseResponse<T> {
  late Response res;
  T? data;
  String? message;
  late bool isSuccessful;
  late bool isServiceDown;
  DioError? error;

  factory BaseResponse.error(DioError error,
      {bool ignore403 = false, String? errorMessage}) {
    BaseResponse<T> res;

    if (error.error is SocketException) {
      res = BaseResponse<T>(null, null, null,
          errorMessage:
              'Looks like there might be an issue with your internet connection. Please try again');
    } else if (errorMessage != null) {
      res = BaseResponse<T>(null, null, null, errorMessage: errorMessage);
    } else if (error.response != null) {
      // "normal" errors
      res = BaseResponse<T>(error.response, null, null);

      if (error.requestOptions.uri != null &&
          (error.requestOptions.uri.host.contains('figure.tech')) &&
          (error.response?.statusCode == 401 ||
              error.response?.statusCode == 403) &&
          BaseService.onTimeout != null) {
        if (!ignore403) {
          if (BaseService.onTimeout != null) {
            BaseService.onTimeout!(BaseService.hasJwt);
          }
        }
      }
    } else {
      // Something happened in setting up or sending the request that triggered an Error
      res = BaseResponse<T>(null, null, null, errorMessage: error.message);
    }

    res.error = error;
    res.isSuccessful = false;
    res.isServiceDown = error.response?.statusCode == 500;
    return res;
  }

  BaseResponse(Response? res, T Function(Map<String, dynamic> json)? converter,
      T Function(List<dynamic> json)? listConverter,
      {String? errorMessage}) {
    isSuccessful = false;
    isServiceDown = false;
    res = res;

    try {
      if (res?.headers != null && res?.headers[AUTH] != null) {
        String auth = res!.headers.value(AUTH)!;
        BaseService.instance.setJwtTokenWithoutInit(auth);
      }
      data = converter == null
          ? listConverter == null
              ? res?.data
              : listConverter(res?.data)
          : converter(res?.data);

      isSuccessful = true;
      isServiceDown = false;
    } catch (e) {
      logError('error parsing: $e');

      isSuccessful = false;
      isServiceDown = res?.statusCode == 500;
    }
    message = (errorMessage == null) ? res?.statusMessage : errorMessage;
  }
}

class BaseService {
  static final BaseService _singleton = BaseService._internal();

  factory BaseService() => _singleton;

  BaseService._internal() {
    _initDio();
  }

  static BaseService get instance => _singleton;
  static String _impersonateId = '';
  static String _organizationUuid = '';
  static SessionTimeoutCallback? onTimeout;
  static bool _isProd = false;
  String _jwtToken = '';
  static late Dio _dio;
  static bool get hasJwt => _singleton.jwtToken.isNotEmpty;

  String get jwtToken => _jwtToken;

  getOrganizationUuid() {
    return _organizationUuid;
  }

  setOrganizationUuid(String uuid) {
    _organizationUuid = uuid;
  }

  getImpersonateId() {
    return _impersonateId;
  }

  setImpersonateId(String id) {
    _impersonateId = id;
  }

  setJwt(String jwt) {
    _jwtToken = jwt;
    _initDio();
  }

  setJwtTokenWithoutInit(String jwt) {
    _jwtToken = jwt;
  }

  setProd(bool isProd) {
    _isProd = isProd;
    _initDio();
  }

  bool get isProd => _isProd;
  String get baseSocketUrl => "wss://${_isProd ? 'www' : 'test'}.figure.tech";

  Map<String, String> get headers {
    if (_jwtToken != null && _jwtToken.isNotEmpty) {
      return {AUTH: _jwtToken};
    }

    return {};
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
    _dio.options.baseUrl = 'https://${_isProd ? 'www' : 'test'}.figure.tech/';
    _dio.interceptors.add(InterceptorsWrapper(onRequest:
        (RequestOptions options, RequestInterceptorHandler handler) async {
      if (options.responseType != ResponseType.bytes) {
        options.headers[ACCEPT] = JSON;
      }
      if (options.headers[CONTENT_TYPE] == null &&
          options.headers[CONTENT_TYPE] != MULTI_PART) {
        options.headers[CONTENT_TYPE] = JSON;
      }
      if (_jwtToken != null && _jwtToken.isNotEmpty) {
        options.headers[AUTH] = _jwtToken;
      }
      if (!isProd && _impersonateId != null && _impersonateId.isNotEmpty) {
        options.headers[IMPERSONATE] = _impersonateId;
      }
      if (_organizationUuid != null && _organizationUuid.isNotEmpty) {
        options.headers['x-org-uuid'] = _organizationUuid;
      }
      return handler.next(options);
    }));

    _dio.interceptors.add(SimpleLogInterceptor());

    if (!_isProd) {
      /// Uncomment to get more detailed request/response info
      // _dio.interceptors.add(LogInterceptor(
      //     request: true,
      //     requestHeader: true,
      //     requestBody: false,
      //     responseHeader: false,
      //     responseBody: false,
      //     error: true));
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
      final res = await _dio.get(path,
          queryParameters: queryStringParameters,
          options: Options(responseType: ResponseType.bytes));
      if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
        final map = res.data as Map<String, dynamic>;
        if (map['errors'] != null && map.length == 1) {
          var error = '';
          if (map['errors'] is List<dynamic>) {
            error = (map['errors'] as List<String>).first;
          } else {
            error = map['errors'];
          }
          return BaseResponse<T>.error(
              DioError(error: error, requestOptions: RequestOptions(path: path)),
              ignore403: true,
              errorMessage: error);
        }
      }
      return BaseResponse<T>(
          res,
          converter == null ? null : (json) => converter(json),
          listConverter == null ? null : (json) => listConverter(json));
    } on DioError catch (e) {
      return BaseResponse<T>.error(e);
    }
  }

  Future<BaseResponse<T>> GET<T>(path,
      {T Function(Map<String, dynamic> json)? converter,
      T Function(List<dynamic> json)? listConverter,
      Map<String, dynamic>? additionalHeaders,
      Map<String, dynamic>? queryStringParameters,
      ResponseType responseType = ResponseType.json,
      bool documentDownload = false,
      bool ignore403 = false}) async {
    if (documentDownload) {
      return downloadDocument(path,
          additionalHeaders: additionalHeaders,
          converter: converter,
          listConverter: listConverter,
          queryStringParameters: queryStringParameters);
    }

    //add additional headers
    if (additionalHeaders != null) {
      _dio.options.headers.addAll(additionalHeaders);
    }

    _dio.options.responseType = responseType;

    try {
      Response res =
          await _dio.get(path, queryParameters: queryStringParameters);
      if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
        final map = res.data as Map<String, dynamic>;
        if (map['errors'] != null && map.length == 1) {
          String error = '';
          if (map['errors'] is List<dynamic>) {
            error = (map['errors'] as List<String>).first;
          } else {
            error = map['errors'];
          }
          return BaseResponse<T>.error(DioError(error: error, requestOptions: RequestOptions(path: path)),
              ignore403: true, errorMessage: error);
        }
      }
      return BaseResponse<T>(
          res,
          converter == null ? null : (json) => converter(json),
          listConverter == null ? null : (json) => listConverter(json));
    } on DioError catch (e) {
      logError('error parsing');
      return BaseResponse<T>.error(e, ignore403: ignore403);
    } catch (e) {
      logError('error parsing');
      return BaseResponse<T>.error(DioError(type: DioErrorType.other, requestOptions: RequestOptions(path: path), error: e.toString()), ignore403: ignore403);
    }
  }

  Future<BaseResponse<T>> DELETE<T>(
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
      Response res = await _dio.delete(path,
          queryParameters: queryStringParameters, data: json.encode(body));
      if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
        final map = res.data as Map<String, dynamic>;
        if (map['errors'] != null && map.length == 1) {
          String error = '';
          if (map['errors'] is List<dynamic>) {
            error = (map['errors'] as List<String>).first;
          } else {
            error = map['errors'];
          }
          return BaseResponse<T>.error(DioError(error: error, requestOptions: RequestOptions(path: path)),
              ignore403: true, errorMessage: error);
        }
      }
      return BaseResponse<T>(
          res,
          converter == null ? null : (json) => converter(json),
          listConverter == null ? null : (json) => listConverter(json));
    } on DioError catch (e) {
      logError('error parsing');
      return BaseResponse<T>.error(e);
    } catch (e) {
      logError('error parsing');
      return BaseResponse<T>.error(DioError(type: DioErrorType.other, requestOptions: RequestOptions(path: path), error: e.toString()));
    }
  }

  Future<BaseResponse<T>> POST<T>(dynamic path,
      {T Function(Map<String, dynamic> json)? converter,
      T Function(List<dynamic> json)? listConverter,
      Map<String, dynamic>? additionalHeaders,
      dynamic body,
      Map<String, String>? queryStringParameters,
      ResponseType responseType = ResponseType.json,
      Encoding? encoding}) async {
    if (additionalHeaders != null) {
      _dio.options.headers.addAll({CONTENT_TYPE: JSON});
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
          if (map['errors'] is List<dynamic>) {
            error = (map['errors'] as List<String>).first;
          } else {
            error = map['errors'];
          }
          return BaseResponse<T>.error(DioError(error: error, requestOptions: RequestOptions(path: path)),
              ignore403: true, errorMessage: error);
        }
      }
      return BaseResponse<T>(
          res,
          converter == null ? null : (json) => converter(json),
          listConverter == null ? null : (json) => listConverter(json));
    } on DioError catch (e) {
      if (e.response?.statusCode == 400 &&
          e.response?.data is Map<String, dynamic>) {
        final map = e.response?.data as Map<String, dynamic>;
        if (map['errors'] != null && map.length == 1) {
          String error = '';
          if (map['errors'] is List<dynamic>) {
            error = (map['errors'] as List<dynamic>).first;
          } else {
            error = map['errors'];
          }
          return BaseResponse<T>.error(DioError(error: error, requestOptions: RequestOptions(path: path)),
              ignore403: true, errorMessage: error);
        }
      }
      return BaseResponse<T>.error(e);
    }
  }

  Future<BaseResponse<T>> PATCH<T>(dynamic path,
      {T Function(Map<String, dynamic> json)? converter,
      T Function(List<dynamic> json)? listConverter,
      Map<String, dynamic>? additionalHeaders,
      dynamic body,
      Map<String, String>? queryStringParameters,
      Encoding? encoding}) async {
    if (additionalHeaders != null) {
      _dio.options.headers.addAll({CONTENT_TYPE: JSON});
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
          if (map['errors'] is List<dynamic>) {
            error = (map['errors'] as List<String>).first;
          } else {
            error = map['errors'];
          }
          return BaseResponse<T>.error(DioError(error: error, requestOptions: RequestOptions(path: path)),
              ignore403: true, errorMessage: error);
        }
      }
      return BaseResponse<T>(
          res,
          converter == null ? null : (json) => converter(json),
          listConverter == null ? null : (json) => listConverter(json));
    } on DioError catch (e) {
      return BaseResponse<T>.error(e);
    } on Error catch (e) {
      return BaseResponse<T>.error(DioError(error: e, requestOptions: RequestOptions(path: path)));
    } catch (e) {
      return BaseResponse<T>.error(DioError(type: DioErrorType.other, requestOptions: RequestOptions(path: path), error: e.toString()));
    }
  }

  Future<BaseResponse<T>> PUT<T>(dynamic path,
      {T Function(Map<String, dynamic> json)? converter,
      T Function(List<dynamic> json)? listConverter,
      Map<String, dynamic>? additionalHeaders,
      dynamic body,
      Map<String, String>? queryStringParameters,
      Encoding? encoding}) async {
    if (additionalHeaders != null) {
      _dio.options.headers.addAll({CONTENT_TYPE: JSON});
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
          if (map['errors'] is List<dynamic>) {
            error = (map['errors'] as List<String>).first;
          } else {
            error = map['errors'];
          }
          return BaseResponse<T>.error(DioError(error: error, requestOptions: RequestOptions(path: path)),
              ignore403: true, errorMessage: error);
        }
      }
      return BaseResponse<T>(
          res,
          converter == null ? null : (json) => converter(json),
          listConverter == null ? null : (json) => listConverter(json));
    } on DioError catch (e) {
      return BaseResponse<T>.error(e);
    } catch (e) {
      return BaseResponse<T>.error(DioError(type: DioErrorType.other, requestOptions: RequestOptions(path: path), error: e.toString()));
    }
  }

  Future<BaseResponse<T>> formPostWithData<T>(dynamic path,
      {T Function(Map<String, dynamic> json)? converter,
      T Function(List<dynamic> json)? listConverter,
      Map<String, dynamic>? additionalHeaders,
      dynamic body,
      ProgressCallback? progressCallback,
      Encoding? encoding}) async {
    Options additionalOptions = Options();
    additionalOptions.headers?.addAll({CONTENT_TYPE: MULTI_PART});

    if (additionalHeaders != null) {
      _dio.options.headers.addAll(additionalHeaders);
    }

    FormData formData = FormData.fromMap({
      'type': body['type'],
    });

    formData.files.add(MapEntry(
        'file', MultipartFile.fromBytes(body['file'], filename: 'file')));

    if (body['uuid'] != null) {
      formData.fields.add(MapEntry('uuid', body['uuid']));
    }

    try {
      Response res = await _dio.post(path,
          options: additionalOptions,
          data: formData, onSendProgress: (count, total) {
        if (progressCallback != null) {
          progressCallback(count, total);
        }
      });
      if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
        final map = res.data as Map<String, dynamic>;
        if (map['errors'] != null && map.length == 1) {
          String error = '';
          if (map['errors'] is List<dynamic>) {
            error = (map['errors'] as List<String>).first;
          } else {
            error = map['errors'];
          }
          return BaseResponse<T>.error(DioError(error: error, requestOptions: RequestOptions(path: path)),
              ignore403: true, errorMessage: error);
        }
      }
      return BaseResponse<T>(
          res,
          converter == null ? null : (json) => converter(json),
          listConverter == null ? null : (json) => listConverter(json));
    } on DioError catch (e) {
      return BaseResponse<T>.error(e);
    }
  }

  Future<dynamic> formPost(dynamic path,
      {Map<String, dynamic>? additionalHeaders,
      dynamic body,
      Encoding? encoding}) async {
    Options additionalOptions = Options();
    if (additionalHeaders != null) {
      additionalOptions.headers?.addAll({CONTENT_TYPE: MULTI_PART});
      _dio.options.headers.addAll(additionalHeaders);
    }

    FormData formData = FormData.fromMap({
      'uuid': body.invoiceUuid,
      'type': body.type,
    });

    formData.files.add(
        MapEntry('file', MultipartFile.fromBytes(body.file, filename: 'file')));

    Response response;
    //upload a video
    response = await _dio
        .post(path, options: additionalOptions, data: formData)
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
}

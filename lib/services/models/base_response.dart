import 'dart:io';

import 'package:dio/dio.dart';
import 'package:provenance_wallet/services/http_client.dart';
import 'package:provenance_wallet/util/logs/logging.dart';

const _serviceDownCodes = {
  404,
  500,
  502,
  503,
};

class BaseResponse<T> {
  BaseResponse(
    Response? res,
    T Function(Map<String, dynamic> json)? converter,
    T Function(List<dynamic> json)? listConverter, {
    String? errorMessage,
    Function? setJwt,
  }) {
    isSuccessful = false;
    isServiceDown = false;
    res = res;

    try {
      if (res?.headers != null &&
          res?.headers[httpHeaderAuth] != null &&
          setJwt != null) {
        var auth = res!.headers.value(httpHeaderAuth)!;
        setJwt(auth);
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
      isServiceDown = _serviceDownCodes.contains(res?.statusCode);
    }
    message = (errorMessage == null) ? res?.statusMessage : errorMessage;
  }

  factory BaseResponse.error(
    DioError error, {
    bool ignore403 = false,
    String? errorMessage,
    SessionTimeoutCallback? onTimeout,
    bool hasJwt = false,
  }) {
    BaseResponse<T> res;

    if (error.error is SocketException) {
      res = BaseResponse<T>(
        null,
        null,
        null,
        errorMessage:
            'Looks like there might be an issue with your internet connection. Please try again',
      );
    } else if (errorMessage != null) {
      res = BaseResponse<T>(
        null,
        null,
        null,
        errorMessage: errorMessage,
      );
    } else if (error.response != null) {
      // "normal" errors
      res = BaseResponse<T>(
        error.response,
        null,
        null,
      );

      if ((error.requestOptions.uri.host.contains('figure.tech')) &&
          (error.response?.statusCode == 401 ||
              error.response?.statusCode == 403) &&
          onTimeout != null) {
        if (!ignore403) {
          onTimeout(hasJwt);
        }
      }
    } else {
      // Something happened in setting up or sending the request that triggered an Error
      res = BaseResponse<T>(
        null,
        null,
        null,
        errorMessage: error.message,
      );
    }

    res.error = error;
    res.isSuccessful = false;
    res.isServiceDown = _serviceDownCodes.contains(error.response?.statusCode);

    return res;
  }

  late Response res;
  T? data;
  String? message;
  late bool isSuccessful;
  late bool isServiceDown;
  DioError? error;
}

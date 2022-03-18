// Mocks generated by Mockito 5.1.0 from annotations
// in provenance_wallet/test/services/transaction_service/default_transaction_service_test.dart.
// Do not manually edit this file.

import 'dart:async' as _i5;
import 'dart:convert' as _i7;

import 'package:dio/dio.dart' as _i6;
import 'package:mockito/mockito.dart' as _i1;
import 'package:provenance_wallet/services/http_client.dart' as _i4;
import 'package:provenance_wallet/services/models/base_response.dart' as _i2;
import 'package:provenance_wallet/services/notification/notification_group.dart'
    as _i10;
import 'package:provenance_wallet/services/notification/notification_info.dart'
    as _i9;
import 'package:provenance_wallet/services/notification/notification_service.dart'
    as _i8;
import 'package:rxdart/streams.dart' as _i3;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types

class _FakeBaseResponse_0<T> extends _i1.Fake implements _i2.BaseResponse<T> {}

class _FakeValueStream_1<T> extends _i1.Fake implements _i3.ValueStream<T> {}

/// A class which mocks [TestHttpClient].
///
/// See the documentation for Mockito's code generation for more information.
class MockTestHttpClient extends _i1.Mock implements _i4.TestHttpClient {
  MockTestHttpClient() {
    _i1.throwOnMissingStub(this);
  }

  @override
  set onTimeout(_i4.SessionTimeoutCallback? _onTimeout) =>
      super.noSuchMethod(Invocation.setter(#onTimeout, _onTimeout),
          returnValueForMissingStub: null);
  @override
  bool get hasJwt =>
      (super.noSuchMethod(Invocation.getter(#hasJwt), returnValue: false)
          as bool);
  @override
  String get jwtToken =>
      (super.noSuchMethod(Invocation.getter(#jwtToken), returnValue: '')
          as String);
  @override
  Map<String, String> get headers =>
      (super.noSuchMethod(Invocation.getter(#headers),
          returnValue: <String, String>{}) as Map<String, String>);
  @override
  dynamic setOrganizationUuid(String? uuid) =>
      super.noSuchMethod(Invocation.method(#setOrganizationUuid, [uuid]));
  @override
  dynamic setJwt(String? jwt) =>
      super.noSuchMethod(Invocation.method(#setJwt, [jwt]));
  @override
  dynamic setJwtTokenWithoutInit(String? jwt) =>
      super.noSuchMethod(Invocation.method(#setJwtTokenWithoutInit, [jwt]));
  @override
  _i5.Future<_i2.BaseResponse<T>> downloadDocument<T>(dynamic path,
          {Map<String, dynamic>? additionalHeaders,
          Map<String, dynamic>? queryStringParameters,
          T Function(Map<String, dynamic>)? converter,
          T Function(List<dynamic>)? listConverter}) =>
      (super.noSuchMethod(
              Invocation.method(#downloadDocument, [
                path
              ], {
                #additionalHeaders: additionalHeaders,
                #queryStringParameters: queryStringParameters,
                #converter: converter,
                #listConverter: listConverter
              }),
              returnValue:
                  Future<_i2.BaseResponse<T>>.value(_FakeBaseResponse_0<T>()))
          as _i5.Future<_i2.BaseResponse<T>>);
  @override
  _i5.Future<_i2.BaseResponse<T>> get<T>(dynamic path,
          {T Function(Map<String, dynamic>)? converter,
          T Function(List<dynamic>)? listConverter,
          Map<String, dynamic>? additionalHeaders,
          Map<String, dynamic>? queryStringParameters,
          _i6.ResponseType? responseType = _i6.ResponseType.json,
          bool? documentDownload = false,
          bool? ignore403 = false}) =>
      (super.noSuchMethod(
              Invocation.method(#get, [
                path
              ], {
                #converter: converter,
                #listConverter: listConverter,
                #additionalHeaders: additionalHeaders,
                #queryStringParameters: queryStringParameters,
                #responseType: responseType,
                #documentDownload: documentDownload,
                #ignore403: ignore403
              }),
              returnValue:
                  Future<_i2.BaseResponse<T>>.value(_FakeBaseResponse_0<T>()))
          as _i5.Future<_i2.BaseResponse<T>>);
  @override
  _i5.Future<_i2.BaseResponse<T>> delete<T>(dynamic path,
          {T Function(Map<String, dynamic>)? converter,
          T Function(List<dynamic>)? listConverter,
          Map<String, dynamic>? additionalHeaders,
          Map<String, dynamic>? queryStringParameters,
          dynamic body}) =>
      (super.noSuchMethod(
              Invocation.method(#delete, [
                path
              ], {
                #converter: converter,
                #listConverter: listConverter,
                #additionalHeaders: additionalHeaders,
                #queryStringParameters: queryStringParameters,
                #body: body
              }),
              returnValue:
                  Future<_i2.BaseResponse<T>>.value(_FakeBaseResponse_0<T>()))
          as _i5.Future<_i2.BaseResponse<T>>);
  @override
  _i5.Future<_i2.BaseResponse<T>> post<T>(dynamic path,
          {T Function(Map<String, dynamic>)? converter,
          T Function(List<dynamic>)? listConverter,
          Map<String, dynamic>? additionalHeaders,
          dynamic body,
          Map<String, String>? queryStringParameters,
          _i6.ResponseType? responseType = _i6.ResponseType.json,
          _i7.Encoding? encoding}) =>
      (super.noSuchMethod(
              Invocation.method(#post, [
                path
              ], {
                #converter: converter,
                #listConverter: listConverter,
                #additionalHeaders: additionalHeaders,
                #body: body,
                #queryStringParameters: queryStringParameters,
                #responseType: responseType,
                #encoding: encoding
              }),
              returnValue:
                  Future<_i2.BaseResponse<T>>.value(_FakeBaseResponse_0<T>()))
          as _i5.Future<_i2.BaseResponse<T>>);
  @override
  _i5.Future<_i2.BaseResponse<T>> patch<T>(dynamic path,
          {T Function(Map<String, dynamic>)? converter,
          T Function(List<dynamic>)? listConverter,
          Map<String, dynamic>? additionalHeaders,
          dynamic body,
          Map<String, String>? queryStringParameters,
          _i7.Encoding? encoding}) =>
      (super.noSuchMethod(
              Invocation.method(#patch, [
                path
              ], {
                #converter: converter,
                #listConverter: listConverter,
                #additionalHeaders: additionalHeaders,
                #body: body,
                #queryStringParameters: queryStringParameters,
                #encoding: encoding
              }),
              returnValue:
                  Future<_i2.BaseResponse<T>>.value(_FakeBaseResponse_0<T>()))
          as _i5.Future<_i2.BaseResponse<T>>);
  @override
  _i5.Future<_i2.BaseResponse<T>> put<T>(dynamic path,
          {T Function(Map<String, dynamic>)? converter,
          T Function(List<dynamic>)? listConverter,
          Map<String, dynamic>? additionalHeaders,
          dynamic body,
          Map<String, String>? queryStringParameters,
          _i7.Encoding? encoding}) =>
      (super.noSuchMethod(
              Invocation.method(#put, [
                path
              ], {
                #converter: converter,
                #listConverter: listConverter,
                #additionalHeaders: additionalHeaders,
                #body: body,
                #queryStringParameters: queryStringParameters,
                #encoding: encoding
              }),
              returnValue:
                  Future<_i2.BaseResponse<T>>.value(_FakeBaseResponse_0<T>()))
          as _i5.Future<_i2.BaseResponse<T>>);
  @override
  _i5.Future<_i2.BaseResponse<T>> formPostWithData<T>(dynamic path,
          {T Function(Map<String, dynamic>)? converter,
          T Function(List<dynamic>)? listConverter,
          Map<String, dynamic>? additionalHeaders,
          dynamic body,
          _i6.ProgressCallback? progressCallback,
          _i7.Encoding? encoding}) =>
      (super.noSuchMethod(
              Invocation.method(#formPostWithData, [
                path
              ], {
                #converter: converter,
                #listConverter: listConverter,
                #additionalHeaders: additionalHeaders,
                #body: body,
                #progressCallback: progressCallback,
                #encoding: encoding
              }),
              returnValue:
                  Future<_i2.BaseResponse<T>>.value(_FakeBaseResponse_0<T>()))
          as _i5.Future<_i2.BaseResponse<T>>);
  @override
  _i5.Future<dynamic> formPost(dynamic path,
          {Map<String, dynamic>? additionalHeaders,
          dynamic body,
          _i7.Encoding? encoding}) =>
      (super.noSuchMethod(
          Invocation.method(#formPost, [
            path
          ], {
            #additionalHeaders: additionalHeaders,
            #body: body,
            #encoding: encoding
          }),
          returnValue: Future<dynamic>.value()) as _i5.Future<dynamic>);
}

/// A class which mocks [NotificationService].
///
/// See the documentation for Mockito's code generation for more information.
class MockNotificationService extends _i1.Mock
    implements _i8.NotificationService {
  MockNotificationService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.ValueStream<List<_i9.NotificationInfo>> get notifications =>
      (super.noSuchMethod(Invocation.getter(#notifications),
              returnValue: _FakeValueStream_1<List<_i9.NotificationInfo>>())
          as _i3.ValueStream<List<_i9.NotificationInfo>>);
  @override
  void notify(_i9.NotificationInfo? notification) =>
      super.noSuchMethod(Invocation.method(#notify, [notification]),
          returnValueForMissingStub: null);
  @override
  void notifyGrouped(_i10.NotificationGroup? group, String? id) =>
      super.noSuchMethod(Invocation.method(#notifyGrouped, [group, id]),
          returnValueForMissingStub: null);
  @override
  void dismiss(String? id) =>
      super.noSuchMethod(Invocation.method(#dismiss, [id]),
          returnValueForMissingStub: null);
  @override
  void dismissGrouped(_i10.NotificationGroup? group, String? id) =>
      super.noSuchMethod(Invocation.method(#dismissGrouped, [group, id]),
          returnValueForMissingStub: null);
}

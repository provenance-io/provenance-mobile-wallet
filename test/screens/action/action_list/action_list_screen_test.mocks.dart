// Mocks generated by Mockito 5.1.0 from annotations
// in provenance_wallet/test/screens/action/action_list/action_list_screen_test.dart.
// Do not manually edit this file.

import 'dart:async' as _i3;

import 'package:mockito/mockito.dart' as _i1;
import 'package:provenance_wallet/screens/action/action_list/action_list_bloc.dart'
    as _i2;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types

/// A class which mocks [ActionListBloc].
///
/// See the documentation for Mockito's code generation for more information.
class MockActionListBloc extends _i1.Mock implements _i2.ActionListBloc {
  MockActionListBloc() {
    _i1.throwOnMissingStub(this);
  }

  @override
  List<_i2.NotificationItem> get notifications =>
      (super.noSuchMethod(Invocation.getter(#notifications),
          returnValue: <_i2.NotificationItem>[]) as List<_i2.NotificationItem>);
  @override
  set notifications(List<_i2.NotificationItem>? _notifications) =>
      super.noSuchMethod(Invocation.setter(#notifications, _notifications),
          returnValueForMissingStub: null);
  @override
  _i3.Stream<_i2.ActionListBlocState> get stream =>
      (super.noSuchMethod(Invocation.getter(#stream),
              returnValue: Stream<_i2.ActionListBlocState>.empty())
          as _i3.Stream<_i2.ActionListBlocState>);
  @override
  void init() => super.noSuchMethod(Invocation.method(#init, []),
      returnValueForMissingStub: null);
  @override
  _i3.Future<void> deleteNotifications(
          List<_i2.NotificationItem>? notifications) =>
      (super.noSuchMethod(
          Invocation.method(#deleteNotifications, [notifications]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i3.Future<void>);
  @override
  _i3.Future<bool> requestApproval(
          _i2.ActionListGroup? group, _i2.ActionListItem? item) =>
      (super.noSuchMethod(Invocation.method(#requestApproval, [group, item]),
          returnValue: Future<bool>.value(false)) as _i3.Future<bool>);
  @override
  _i3.Future<void> processWalletConnectQueue(bool? approved,
          _i2.ActionListGroup? group, _i2.ActionListItem? item) =>
      (super.noSuchMethod(
          Invocation.method(
              #processWalletConnectQueue, [approved, group, item]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i3.Future<void>);
}

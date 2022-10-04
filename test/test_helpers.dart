import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/subjects.dart';

class StreamHasListener<X> extends Matcher {
  StreamHasListener(this._hasListener);

  final bool _hasListener;

  @override
  Description describe(Description description) =>
      description.add('has listener');

  @override
  bool matches(item, Map matchState) {
    final publistSubject = item as StreamController<X>;
    return _hasListener == publistSubject.hasListener;
  }
}

class StreamClosed<X> extends Matcher {
  StreamClosed(this._isClosed);

  final bool _isClosed;

  @override
  Description describe(Description description) => description.add('is Closed');

  @override
  bool matches(item, Map matchState) {
    final publistSubject = item as StreamController<X>;
    return _isClosed == publistSubject.isClosed;
  }
}

extension PostExpectationnHelper<X> on PostExpectation<Future<X>> {
  void thenFuture(X value) => thenAnswer((_) => Future.value(value));
}
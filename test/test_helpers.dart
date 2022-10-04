import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provenance_dart/wallet.dart';

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

class PrivateKeyMatcher extends Matcher {
  PrivateKeyMatcher(this.privKey);

  final PrivateKey privKey;

  @override
  Description describe(Description description) => description;

  @override
  bool matches(item, Map matchState) {
    final key = item as PrivateKey;
    return ListEquality().equals(key.raw, privKey.raw) &&
        key.coin == privKey.coin &&
        ListEquality().equals(key.chainCode, privKey.chainCode);
  }
}

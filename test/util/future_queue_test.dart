import 'package:flutter_test/flutter_test.dart';
import 'package:provenance_wallet/util/future_queue.dart';

void main() {
  Future<void> createDelayed(int sec) async {
    print('start $sec');
    await Future.delayed(Duration(seconds: sec));
    print('end $sec');
  }

  test('description', () async {
    final q = FutureQueue();

    q.add(() => createDelayed(3));

    q.add(() => createDelayed(1));

    await Future.delayed(Duration(seconds: 5));
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:provenance_wallet/util/lazy.dart';

void main() {
  test('Given create with return value, then value is returned.', () {
    const value = 1;
    int create() {
      return value;
    }

    final lazy = Lazy(create);

    expect(lazy.value, value);
  });

  test(
    'Given create with void return value, then create is called when accessing value',
    () {
      var calls = 0;
      void create() {
        calls++;

        return;
      }

      final lazy = Lazy(create);

      lazy.value;

      expect(calls, 1);
    },
  );

  test('Given multiple calls for value, then create is only called once.', () {
    var calls = 0;
    int create() {
      calls++;

      return 1;
    }

    final lazy = Lazy(create);

    lazy.value;
    lazy.value;

    expect(calls, 1);
  });

  test(
    'Given error in create, then error is thrown on every call for value.',
    () {
      int create() {
        throw ArgumentError();
      }

      final lazy = Lazy(create);

      expect(() => lazy.value, throwsArgumentError);
      expect(() => lazy.value, throwsArgumentError);
    },
  );

  test(
    'Given error in create Future, then every await on future throws.',
    () async {
      Future<int> create() async {
        await null;

        throw ArgumentError();
      }

      final lazy = Lazy(create);

      expect(lazy.value, throwsArgumentError);
      expect(lazy.value, throwsArgumentError);
    },
  );
}

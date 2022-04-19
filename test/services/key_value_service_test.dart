import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/services/key_value_service/default_key_value_service.dart';
import 'package:provenance_wallet/services/key_value_service/key_value_service.dart';
import 'package:provenance_wallet/services/key_value_service/memory_key_value_store.dart';

void main() {
  test(
    'Given empty key store then stream returns data with null value',
    () async {
      final service = DefaultKeyValueService(
        store: MemoryKeyValueStore(),
      );

      final streamBool = service.stream<bool>(PrefKey.testBool);
      await expectLater(streamBool, emits(KeyValueData<bool>()));
    },
  );

  test(
    'Given key store with value then stream returns data with value',
    () async {
      const valueBool = true;
      const valueString = 'test';
      final valueDate = DateTime.now();
      final service = DefaultKeyValueService(
        store: MemoryKeyValueStore(
          data: {
            PrefKey.testBool.name: valueBool,
            PrefKey.testString.name: valueString,
            PrefKey.testDateTime.name: valueDate,
          },
        ),
      );

      final streamBool = service.stream<bool>(PrefKey.testBool);
      await expectLater(
        streamBool,
        emits(KeyValueData(data: valueBool)),
      );

      final streamString = service.stream<String>(PrefKey.testString);
      await expectLater(
        streamString,
        emits(KeyValueData(data: valueString)),
      );

      final streamDateTime = service.stream<DateTime>(PrefKey.testDateTime);
      await expectLater(
        streamDateTime,
        emits(KeyValueData(data: valueDate)),
      );
    },
  );

  test(
    'Given key store with value then stream incorrect type throws error',
    () async {
      final service = DefaultKeyValueService(
        store: MemoryKeyValueStore(
          data: {
            PrefKey.testBool.name: true,
          },
        ),
      );

      Object? errorBool;
      runZonedGuarded(
        () {
          service.stream<String>(PrefKey.testBool);
        },
        (e, s) {
          errorBool = e;
        },
      );

      await pumpEventQueue();

      expect(errorBool, isNotNull);
    },
  );

  test(
    'Given empty key store and get stream before set value then stream returns value',
    () async {
      const value = true;
      final service = DefaultKeyValueService(
        store: MemoryKeyValueStore(),
      );

      final stream = service.stream<bool>(PrefKey.testBool);

      service.setBool(PrefKey.testBool, value);

      await expectLater(
        stream,
        emitsInOrder(
          [
            KeyValueData<bool>(),
            KeyValueData(data: value),
          ],
        ),
      );
    },
  );

  testWidgets(
    'Given key store with value and uninitialized stream then StreamBuilder.build yields null then value',
    (tester) async {
      const value = true;
      final service = DefaultKeyValueService(
        store: MemoryKeyValueStore(
          data: {
            PrefKey.testBool.name: value,
          },
        ),
      );

      final stream = service.stream<bool>(PrefKey.testBool);

      var i = 0;

      await tester.pumpWidget(StreamBuilder<KeyValueData<bool>>(
        initialData: stream.valueOrNull,
        stream: stream,
        builder: (context, snapshot) {
          if (i == 0) {
            expect(
              snapshot.data,
              isNull,
              reason: 'Build $i did not yield null snapshot',
            );
          } else if (i == 1) {
            expect(
              snapshot.data?.data,
              value,
              reason: 'Build $i did not yield $value',
            );
          }

          i++;

          return Container();
        },
      ));

      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'Given key store with value and initialized stream then StreamBuilder.build yields value',
    (tester) async {
      const value = true;
      final service = DefaultKeyValueService(
        store: MemoryKeyValueStore(
          data: {
            PrefKey.testBool.name: value,
          },
        ),
      );

      final stream = service.stream<bool>(PrefKey.testBool);

      await tester.pumpAndSettle();

      await tester.pumpWidget(StreamBuilder<KeyValueData<bool>>(
        initialData: stream.valueOrNull,
        stream: stream,
        builder: (context, snapshot) {
          expect(
            snapshot.data?.data,
            value,
            reason: 'Build did not yield $value',
          );

          return Container();
        },
      ));

      await tester.pumpAndSettle();
    },
  );
}

import 'package:flutter_test/flutter_test.dart';
import 'package:provenance_wallet/util/paging_util.dart';

void main() {
  test('Full pages yield correct page count', () {
    final count = getPageCount(
      total: 4,
      pageSize: 2,
    );

    expect(count, 2);
  });

  test('Partial page yields correct page count', () {
    final count = getPageCount(
      total: 5,
      pageSize: 2,
    );

    expect(count, 3);
  });

  test('Partial pages yields correct page index', () {
    const pageSize = 2;

    final tests = {
      0: 0,
      1: 0,
      2: 1,
      3: 1,
      4: 2,
    };

    for (var test in tests.entries) {
      final pageIndex = getPageIndexForItemIndex(
        pageSize: pageSize,
        itemIndex: test.key,
      );

      expect(pageIndex, test.value);
    }
  });

  test('Full pages yield correct page index', () {
    const pageSize = 3;

    final tests = {
      0: 0,
      1: 0,
      2: 0,
      3: 1,
      4: 1,
      5: 1,
    };

    for (var test in tests.entries) {
      final pageIndex = getPageIndexForItemIndex(
        pageSize: pageSize,
        itemIndex: test.key,
      );

      expect(pageIndex, test.value);
    }
  });

  test('Given zero page size then getPageIndexForItemIndex throws', () {
    expect(
      () => getPageIndexForItemIndex(pageSize: 0, itemIndex: 0),
      throwsArgumentError,
    );
  });

  test('Even page size yields correct item index', () {
    const pageSize = 2;

    final tests = {
      0: 0,
      1: 2,
      2: 4,
    };

    for (var test in tests.entries) {
      final itemIndex = getFirstItemIndexForPageIndex(
        pageSize: pageSize,
        pageIndex: test.key,
      );

      expect(itemIndex, test.value);
    }
  });

  test('Odd page size yields correct item index', () {
    const pageSize = 3;

    final tests = {
      0: 0,
      1: 3,
      2: 6,
    };

    for (var test in tests.entries) {
      final itemIndex = getFirstItemIndexForPageIndex(
        pageSize: pageSize,
        pageIndex: test.key,
      );

      expect(itemIndex, test.value);
    }
  });

  test('Given zero page size then getFirstItemIndexForPageIndex throws', () {
    expect(
      () => getFirstItemIndexForPageIndex(pageSize: 0, pageIndex: 0),
      throwsArgumentError,
    );
  });

  test('Item list with partial page yields correct pages', () {
    const pageSize = 2;
    const items = [0, 1, 2, 3, 4];

    final tests = {
      0: [0, 1],
      1: [2, 3],
      2: [4],
    };

    for (var test in tests.entries) {
      final page = getPage(
        pageSize: pageSize,
        pageIndex: test.key,
        items: items,
      );

      expect(page, test.value);
    }
  });

  test('Yields correct item index within page', () {
    const pageSize = 3;
    const tests = {
      0: 0,
      1: 1,
      2: 2,
      3: 0,
      4: 1,
      5: 2,
    };

    for (var test in tests.entries) {
      final itemIndex = getItemIndexWithinPage(
        pageSize: pageSize,
        itemIndex: test.key,
      );

      expect(itemIndex, test.value);
    }
  });

  test('Item list without partial page yields correct pages', () {
    const pageSize = 3;
    const items = [0, 1, 2, 3, 4, 5];

    final tests = {
      0: [0, 1, 2],
      1: [3, 4, 5],
    };

    for (var test in tests.entries) {
      final page = getPage(
        pageSize: pageSize,
        pageIndex: test.key,
        items: items,
      );

      expect(page, test.value);
    }
  });

  test('Given out of range page index, null is returned', () {
    final page = getPage(
      pageSize: 2,
      pageIndex: 1,
      items: [0, 1],
    );

    expect(page, isNull);
  });
}

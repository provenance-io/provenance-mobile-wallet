import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:provenance_wallet/common/classes/pw_paging_cache.dart';
import 'package:rxdart/subjects.dart';

class _TestPwPagingCache extends PwPagingCache {
  _TestPwPagingCache(
    int itemCount,
  ) : super(itemCount);

  @override
  FutureOr onDispose() {}

  @override
  Future<List<T>> loadMore<T>(
          List<T> oldList,
          BehaviorSubject<int> pages,
          BehaviorSubject<bool> isLoading,
          Future<List<T>> Function() function) async =>
      super.loadMore<T>(oldList, pages, isLoading, function);
}

main() {
  late BehaviorSubject<int> pages;
  late BehaviorSubject<bool> loading;
  late _TestPwPagingCache pagingCache;

  setUp(() {
    pages = BehaviorSubject<int>.seeded(1);
    loading = BehaviorSubject<bool>.seeded(false);

    pagingCache = _TestPwPagingCache(2);
  });

  test("test asserts", () async {
    expect(_TestPwPagingCache(-1), isNotNull);
    expect(_TestPwPagingCache(0), isNotNull);
    expect(_TestPwPagingCache(2), isNotNull);
  });

  test("the returned list is a new list", () async {
    final originalList = [1, 2, 3];
    final updatedList = [4, 5, 6];

    final returnedList = await pagingCache.loadMore(
        originalList, pages, loading, () => Future.value(updatedList));
    expect(returnedList != originalList, true);
    expect(returnedList == updatedList, true);
  });

  test("The notifiers are updated through the flow", () async {
    final originalList = [1, 2, 3];
    final updatedList = [4, 5, 6];

    // NOTE: the loading cache does not mark the loading as complete
    expectLater(loading, emitsInOrder([emits(false), emits(true)]));

    expectLater(pages, emitsInOrder([emits(1), emits(2), emits(3)]));

    final results1 = await pagingCache.loadMore(
        originalList, pages, loading, () => Future.value(updatedList));

    await pagingCache.loadMore(
        results1, pages, loading, () => Future.value(updatedList));
  });

  test("The final list is the concatenation of the existing and returned lists",
      () async {
    final originalList = [1, 2, 3];

    final results1 = await pagingCache.loadMore(
        originalList, pages, loading, () => Future.value([4, 5, 6]));

    final results2 = await pagingCache.loadMore(
        results1, pages, loading, () => Future.value([7, 8, 9]));

    expect(results1, [
      1,
      2,
      3,
      4,
      5,
      6,
    ]);
    expect(results2, [
      1,
      2,
      3,
      4,
      5,
      6,
      7,
      8,
      9,
    ]);
  });

  test(
      'the old list is returned if you already have a list where length > itemCount',
      () async {
    pagingCache = _TestPwPagingCache(2);
    final originalList =
        List.generate(pagingCache.itemCount - 1, (index) => index);
    final returnedList = await pagingCache.loadMore(originalList, pages,
        loading, () => Future.error(Exception("Should not be invoked")));

    // ensure that the returned list not only contains the same items, but that the actual list object is the same.
    expect(returnedList, returnedList);
  });

  test(
      "returning the original list is determined by page.value and the constructor item amount",
      () async {
    final originalList = [1, 2, 3];
    final updatedList = [4, 5, 6];

    pages.value = 2; // 2 * pagingCache.itemCount > originalList.length
    final results1 = await pagingCache.loadMore(
        originalList, pages, loading, () => Future.value(updatedList));
    expect(results1, originalList);

    pages.value = 1;
    final results2 = await pagingCache.loadMore(
        originalList, pages, loading, () => Future.value(updatedList));
    expect(results2, [1, 2, 3, 4, 5, 6]);
  });
}

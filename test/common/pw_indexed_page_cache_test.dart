import 'package:flutter_test/flutter_test.dart';
import 'package:provenance_wallet/common/pw_indexed_page_cache.dart';
import 'package:provenance_wallet/util/paging_util.dart';

void main() {
  const _items = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];

  Future<LoadResult<int>?> _load({
    required pageSize,
    required pageIndex,
  }) async {
    LoadResult<int>? result;

    final page = getPage(
      pageSize: pageSize,
      pageIndex: pageIndex,
      items: _items,
    );

    if (page != null) {
      result = LoadResult(
        itemCount: _items.length,
        items: page,
      );
    }

    return result;
  }

  test('Fetches correct item', () async {
    final cache = PwIndexedPageCache(
      pageSize: 2,
      load: _load,
    );

    for (var i = 0; i < _items.length; i++) {
      final item = await cache.getItemAtIndex(i);

      expect(item, _items[i]);
    }
  });

  test('Initializing cache emits state updates', () async {
    final cache = PwIndexedPageCache(
      pageSize: 2,
      load: _load,
    );

    cache.getItemAtIndex(0);

    expectLater(
      cache.state,
      emitsInOrder(
        [
          CacheInitState(),
          CacheReadyState(
            itemCount: _items.length,
          ),
        ],
      ),
    );
  });

  test('Clearing cache emits state updates', () async {
    final cache = PwIndexedPageCache(
      pageSize: 2,
      load: _load,
    );

    cache.getItemAtIndex(0);

    await cache.state.firstWhere((e) => e is CacheReadyState);

    cache.clearCache();

    expectLater(
      cache.state,
      emitsInOrder(
        [
          CacheInitState(),
          CacheReadyState(
            itemCount: _items.length,
          ),
        ],
      ),
    );
  });

  test('Change in item total resets cache', () async {
    final items = [1, 2, 3];

    Future<LoadResult<int>?> load({
      required pageSize,
      required pageIndex,
    }) async {
      LoadResult<int>? result;

      final page = getPage(
        pageSize: pageSize,
        pageIndex: pageIndex,
        items: items,
      );

      if (page != null) {
        result = LoadResult(
          itemCount: items.length,
          items: page,
        );
      }

      return result;
    }

    const pageSize = 2;

    final cache = PwIndexedPageCache(
      pageSize: pageSize,
      load: load,
    );

    await cache.getItemAtIndex(0);

    const insertedIndex = 0;
    items.insert(insertedIndex, 0);

    // Get uncached page to trigger a load
    await cache.getItemAtIndex(pageSize);

    expect(
      cache.state,
      emits(
        CacheReadyState(
          itemCount: items.length,
        ),
      ),
    );

    for (var i = 0; i < items.length; i++) {
      final item = await cache.getItemAtIndex(i);

      expect(item, items[i]);
    }
  });

  test('Initialization failure emits state update', () async {
    Future<LoadResult<int>?> load({
      required pageSize,
      required pageIndex,
    }) async {
      return null;
    }

    final cache = PwIndexedPageCache(
      pageSize: 2,
      load: load,
    );

    expectLater(
      cache.state,
      emitsInOrder(
        [
          CacheInitState(),
          CacheErrorState(
            error: CacheError.loadFailed,
          ),
        ],
      ),
    );
  });

  test('Subsequent load failure returns null item', () async {
    var i = 0;

    Future<LoadResult<int>?> load({
      required pageSize,
      required pageIndex,
    }) async {
      i++;
      if (i == 1) {
        return LoadResult(
          itemCount: _items.length,
          items: _items,
        );
      } else {
        return null;
      }
    }

    const pageSize = 2;

    final cache = PwIndexedPageCache(
      pageSize: pageSize,
      load: load,
    );

    await cache.getItemAtIndex(0);

    final item = await cache.getItemAtIndex(pageSize);

    expect(item, isNull);
  });

  test('Initial throwing load func emits state update', () async {
    Future<LoadResult<int>?> load({
      required pageSize,
      required pageIndex,
    }) async {
      throw 'Test error';
    }

    final cache = PwIndexedPageCache(
      pageSize: 2,
      load: load,
    );

    expectLater(
      cache.state,
      emitsInOrder(
        [
          CacheInitState(),
          CacheErrorState(
            error: CacheError.loadFailed,
          ),
        ],
      ),
    );
  });

  test('Subsequent throwing load func returns null item', () async {
    var i = 0;

    Future<LoadResult<int>?> load({
      required pageSize,
      required pageIndex,
    }) async {
      i++;
      if (i == 1) {
        return LoadResult(
          itemCount: _items.length,
          items: _items,
        );
      } else {
        throw 'Test error';
      }
    }

    const pageSize = 2;

    final cache = PwIndexedPageCache(
      pageSize: pageSize,
      load: load,
    );

    // Get uncached page to trigger a load
    final item = await cache.getItemAtIndex(pageSize);

    expect(item, isNull);
  });
}

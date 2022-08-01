import 'package:provenance_wallet/extension/stream_controller.dart';
import 'package:provenance_wallet/util/logs/logging.dart';
import 'package:provenance_wallet/util/paging_util.dart';
import 'package:rxdart/subjects.dart';

class PwIndexedPageCache<T> {
  PwIndexedPageCache({
    required int pageSize,
    required LoadFunc<T> load,
  })  : _pageSize = pageSize,
        _load = load {
    _init();
  }

  final int _pageSize;
  final LoadFunc<T> _load;

  final _loadCache = <int, Future<LoadResult<T>?>>{};
  final _state = BehaviorSubject<CacheState>.seeded(CacheInitState());

  Stream<CacheState?> get state => _state;

  Future<T?> getItemAtIndex(int itemIndex) => _getItemAtIndex(itemIndex, 1);

  void clearCache() {
    _clearCache(CacheInitState());
    _init();
  }

  void dispose() {
    _state.close();
  }

  Future<T?> _getItemAtIndex(int itemIndex, int tryNum) async {
    final pageIndex = getPageIndexForItemIndex(
      pageSize: _pageSize,
      itemIndex: itemIndex,
    );

    if (!_loadCache.containsKey(pageIndex)) {
      _loadCache[pageIndex] = _load(
        pageSize: _pageSize,
        pageIndex: pageIndex,
      );
    }

    T? item;

    LoadResult? result;
    try {
      result = await _loadCache[pageIndex]!;
    } catch (e) {
      logError('Load error', error: e);
    }

    if (result != null) {
      final verified = _verifyResult(result);
      if (verified) {
        final itemIndexWithinPage = getItemIndexWithinPage(
          pageSize: _pageSize,
          itemIndex: itemIndex,
        );

        item = result.items[itemIndexWithinPage];
      } else {
        _clearCache(
          CacheReadyState(
            itemCount: result.itemCount,
          ),
        );
      }
    } else {
      // Load failed, try again
      _loadCache.remove(pageIndex);

      const maxTries = 2;
      if (tryNum <= maxTries) {
        item = await _getItemAtIndex(itemIndex, tryNum + 1);
      }
    }

    return item;
  }

  bool _verifyResult(LoadResult result) {
    final state = _state.value;

    // Ideally this would verify a hash returned by load, but we'll
    // go with checking the itemCount for now.
    return state is CacheReadyState
        ? state.itemCount == result.itemCount
        : true;
  }

  void _clearCache(CacheState state) {
    _loadCache.clear();
    _state.tryAdd(state);
  }

  Future<void> _init() async {
    const pageIndex = 0;
    final load = _load(
      pageSize: _pageSize,
      pageIndex: pageIndex,
    );
    _loadCache[pageIndex] = load;

    LoadResult? result;
    try {
      result = await load;
    } catch (e) {
      logError('Initial load error', error: e);
    }

    final cacheState = result == null
        ? CacheErrorState(
            error: CacheError.loadFailed,
          )
        : CacheReadyState(
            itemCount: result.itemCount,
          );

    _state.tryAdd(cacheState);
  }
}

typedef LoadFunc<T> = Future<LoadResult<T>?> Function({
  required int pageSize,
  required int pageIndex,
});

class LoadResult<T> {
  LoadResult({
    required this.itemCount,
    required this.items,
  });

  final int itemCount;
  final List<T> items;
}

abstract class CacheState {
  CacheState._();
}

class CacheInitState implements CacheState {
  final kind = CacheStateKind.init;

  @override
  operator ==(Object other) => other is CacheInitState;

  @override
  int get hashCode => kind.hashCode;
}

class CacheReadyState implements CacheState {
  CacheReadyState({
    required this.itemCount,
  });

  final kind = CacheStateKind.ready;
  final int itemCount;

  @override
  operator ==(Object other) =>
      other is CacheReadyState && other.itemCount == itemCount;

  @override
  int get hashCode => Object.hash(itemCount.hashCode, kind);
}

class CacheErrorState implements CacheState {
  CacheErrorState({
    required this.error,
  });

  final kind = CacheStateKind.error;
  final CacheError error;

  @override
  operator ==(Object other) => other is CacheErrorState && other.error == error;

  @override
  int get hashCode => Object.hash(kind, error);
}

enum CacheError {
  loadFailed,
}

enum CacheStateKind {
  init,
  ready,
  error,
}

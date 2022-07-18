import 'package:get_it/get_it.dart';
import 'package:provenance_wallet/common/pw_design.dart';
import 'package:rxdart/rxdart.dart';

// TODO: Make tests for me!

abstract class PwPagingCache extends Disposable {
  @visibleForTesting
  final int itemCount;

  PwPagingCache(
    this.itemCount,
  );

  @protected
  Future<List<T>> loadMore<T>(
      List<T> oldList,
      BehaviorSubject<int> pages,
      BehaviorSubject<bool> isLoading,
      Future<List<T>> Function() function) async {
    if (pages.value * itemCount > oldList.length) {
      return oldList;
    }
    pages.value++;
    isLoading.value = true;
    final newList = await function();

    newList.insertAll(0, oldList);
    return newList;
  }
}

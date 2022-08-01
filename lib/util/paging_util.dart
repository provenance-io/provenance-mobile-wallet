import 'dart:math';

int getPageCount({
  required int total,
  required int pageSize,
}) {
  return (total / pageSize).ceil();
}

int getPageIndexForItemIndex({
  required int pageSize,
  required int itemIndex,
}) {
  if (pageSize == 0) {
    throw ArgumentError.value(pageSize, 'pageSize', 'Cannot be zero');
  }

  return (itemIndex / pageSize).floor();
}

int getFirstItemIndexForPageIndex({
  required int pageSize,
  required int pageIndex,
}) {
  if (pageSize == 0) {
    throw ArgumentError.value(pageSize, 'pageSize', 'Cannot be zero');
  }

  return pageSize * pageIndex;
}

int getItemIndexWithinPage({
  required int pageSize,
  required int itemIndex,
}) {
  return itemIndex % pageSize;
}

List<T>? getPage<T>({
  required int pageSize,
  required int pageIndex,
  required List<T> items,
}) {
  final firstItemIndex = getFirstItemIndexForPageIndex(
    pageSize: pageSize,
    pageIndex: pageIndex,
  );

  if (firstItemIndex >= items.length) {
    return null;
  }

  final lastIndexNonInclusive = min(
    firstItemIndex + pageSize,
    items.length,
  );

  return items.sublist(
    firstItemIndex,
    lastIndexNonInclusive,
  );
}

// TODO-Roy: Move to list_extension.dart
extension ListExtension<T> on List<T> {
  void sortDescendingBy(Comparable Function(T e) get) {
    sort((a, b) => get(b).compareTo(get(a)));
  }

  void sortDescendingWithFallback({
    required Comparable Function(T e) get,
    required Comparable Function(T e) fallback,
  }) {
    sort((a, b) {
      int result = get(b).compareTo(get(a));
      if (result != 0) {
        return result;
      }
      return fallback(b).compareTo(fallback(a));
    });
  }

  void sortAscendingBy(Comparable Function(T) get) {
    sort((a, b) => get(a).compareTo(get(b)));
  }
}

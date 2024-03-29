extension ListExtension<T> on List<T> {
  void sortDescendingBy(Comparable Function(T e) get) {
    sort((a, b) => get(b).compareTo(get(a)));
  }

  void sortAscendingBy(Comparable Function(T) get) {
    sort((a, b) => get(a).compareTo(get(b)));
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
}

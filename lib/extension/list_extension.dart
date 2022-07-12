extension ListExtension<T> on List<T> {
  void sortDescendingBy(Comparable Function(T e) get) {
    sort((a, b) => get(b).compareTo(get(a)));
  }

  void sortAscendingBy(Comparable Function(T) get) {
    sort((a, b) => get(a).compareTo(get(b)));
  }
}

class Lazy<T> {
  Lazy(T Function() create) : _create = create;

  final T Function() _create;

  T? _value;

  T get value => _value ??= _create();
}

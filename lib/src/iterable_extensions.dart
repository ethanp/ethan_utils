/// Extensions on Iterable.
extension IterableExtensions<T> on Iterable<T> {
  /// Map to List.
  List<U> mapL<U>(U Function(T) f) => map(f).toList();

  /// Where to List.
  List<T> whereL(bool Function(T) f) => where(f).toList();

  /// Check if all elements satisfy predicate.
  bool all(bool Function(T) f) => !any((e) => !f(e));

  /// Get last element or null if empty.
  T? get maybeLast => isEmpty ? null : last;

  /// Map with index.
  Iterable<U> mapWithIndex<U>(U Function(T elem, int index) f) sync* {
    int i = 0;
    for (final item in this) {
      yield f(item, i++);
    }
  }

  /// Get indices as iterable.
  Iterable<int> get indices sync* {
    int i = 0;
    for (final _ in this) {
      yield i++;
    }
  }

  /// Zip with index.
  Iterable<(T, int)> get zipWithIndex sync* {
    int i = 0;
    for (final e in this) {
      yield (e, i++);
    }
  }

  /// Find element with minimum value by selector.
  T minBy<U extends Comparable<U>>(U Function(T) fn) =>
      reduce((prev, curr) => fn(prev).compareTo(fn(curr)) < 0 ? prev : curr);

  /// Find element with maximum value by selector.
  T maxBy<U extends Comparable<U>>(U Function(T) fn) =>
      reduce((prev, curr) => fn(prev).compareTo(fn(curr)) < 0 ? curr : prev);

  /// Sum by selector.
  double sumBy(double Function(T) fn) => map(fn).fold(0, (a, b) => a + b);

  /// Average by selector.
  double avgBy(double Function(T) fn) => sumBy(fn) / length;

  /// Insert separator between elements.
  List<T> separatedBy(T separator) =>
      expand((e) => [e, separator]).toList()..removeLast();
}

/// Extensions for nested iterables.
extension FlattenableExtensions<T> on Iterable<Iterable<T>> {
  /// Flatten nested iterable.
  Iterable<T> get flatten => expand((e) => e);
}

/// Extensions for numeric iterables.
extension NumIterableExtensions on Iterable<num> {
  /// Sum of all elements.
  double get sum => isEmpty ? 0 : fold<double>(0, (a, b) => a + b);
}

/// Extensions for Comparable iterables.
extension ComparableIterableExtensions<T extends Comparable<T>> on Iterable<T> {
  /// Minimum element.
  T get min => minBy((t) => t);

  /// Maximum element.
  T get max => maxBy((t) => t);
}

/// Extensions for numeric iterables (int, double).
/// Needed because `num` extends `Comparable<num>`, not `Comparable<T>`.
extension NumericMinMaxExtensions<T extends num> on Iterable<T> {
  /// Minimum element.
  T get min => minBy<num>((t) => t);

  /// Maximum element.
  T get max => maxBy<num>((t) => t);
}

import 'dart:math' as math;

/// Extensions on List.
extension ListExtensions<T> on List<T> {
  /// Sort in place by selector.
  void sortOn<U extends Comparable>(
    U Function(T) fn, {
    bool descending = false,
  }) =>
      sort(
        (a, b) => descending ? fn(b).compareTo(fn(a)) : fn(a).compareTo(fn(b)),
      );

  /// Return sorted copy by selector.
  List<T> sortedOn<U extends Comparable>(
    U Function(T) fn, {
    bool descending = false,
  }) =>
      [...this]..sortOn(fn, descending: descending);

  /// Group elements by key.
  Map<U, List<T>> groupBy<U>(U Function(T) fn) {
    final result = <U, List<T>>{};
    for (final elem in this) {
      final key = fn(elem);
      result.putIfAbsent(key, () => []);
      result[key]!.add(elem);
    }
    return Map.unmodifiable(result);
  }

  /// Keep only the last n elements.
  List<T> keepLast({required int atMost}) =>
      sublist(math.max(length - atMost, 0));

  /// Zip adjacent elements with a difference offset.
  ///
  /// You provide a function which takes each element paired with the
  /// element [diff] positions away, and returns a value.
  ///
  /// If `diff=n`, the resulting iterable will have `length = orig.length - n`.
  Iterable<B> zipWithDiff<B>(int diff, B Function(T curr, T diffAway) f) sync* {
    int i = math.max(0, -diff);
    int j = math.max(0, diff);

    while (math.max(i, j) < length) {
      yield f(this[i++], this[j++]);
    }
  }
}

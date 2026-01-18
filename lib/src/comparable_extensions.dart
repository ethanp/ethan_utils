/// Extensions on Comparable types.
extension ComparableExtensions<T extends Comparable<T>> on T {
  /// Less than comparison.
  bool operator <(T other) => compareTo(other) < 0;

  /// Greater than comparison.
  bool operator >(T other) => compareTo(other) > 0;

  /// Less than or equal comparison.
  bool operator <=(T other) => compareTo(other) <= 0;

  /// Greater than or equal comparison.
  bool operator >=(T other) => compareTo(other) >= 0;

  /// Return the smaller of this and other.
  T min(T other) => this < other ? this : other;

  /// Return the larger of this and other.
  T max(T other) => this > other ? this : other;
}

/// Extensions on nullable types.
extension NullableExtensions<T> on T? {
  /// Transform the value if non-null, otherwise return null.
  /// Similar to Kotlin's `?.let { }` or Rust's `Option::map`.
  U? map<U>(U Function(T) f) => this == null ? null : f(this as T);
}

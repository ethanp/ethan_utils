import 'package:flutter/cupertino.dart';

extension ContextExtensions on BuildContext {
  /// Push a Cupertino page route with a builder.
  Future<T?> push<T>(Widget Function(BuildContext context) builder) {
    return Navigator.of(this).push<T>(
      CupertinoPageRoute(builder: builder),
    );
  }
}

import 'package:flutter/material.dart';

extension ContextTextSnackBar on BuildContext {
  void textSnackBar(
    String message, {
    Duration duration = const Duration(milliseconds: 4000),
  }) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(content: Text(message), duration: duration),
    );
  }
}

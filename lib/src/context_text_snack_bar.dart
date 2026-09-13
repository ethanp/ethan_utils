import 'package:flutter/material.dart';

import 'logger.dart';

const _log = ELogger('SnackBar');

extension ContextTextSnackBar on BuildContext {
  void textSnackBar(
    String message, {
    Duration duration = const Duration(milliseconds: 4000),
  }) {
    _log.log(message);
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: SelectableText(message),
        duration: duration,
      ),
    );
  }
}

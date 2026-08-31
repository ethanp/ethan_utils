import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

extension ContextExtensions on BuildContext {
  void showInfoOrErrorAlert(String message, {bool isError = false}) {
    showDialog<void>(
      context: this,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(isError ? 'Error' : 'Info'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
            },
            child: const Text('Ok'),
          ),
        ],
      ),
    );
  }

  Future<T?> push<T>(Widget widget) {
    return Navigator.of(this)
        .push<T>(CupertinoPageRoute(builder: (_) => widget));
  }

  void pushReplacementPage(Widget widget) {
    Navigator.of(this)
        .pushReplacement(CupertinoPageRoute(builder: (_) => widget));
  }

  void pop<T>([T? result]) => Navigator.of(this).pop(result);

  void popUntilFirst<T>([T? result]) {
    Navigator.of(this).popUntil((route) => route.isFirst);
  }
}

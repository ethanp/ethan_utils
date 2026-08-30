import 'package:flutter/cupertino.dart';

extension ContextExtensions on BuildContext {
  void showSnackBar(String message, {bool isError = false}) {
    showCupertinoDialog(
      context: this,
      builder: (BuildContext dialogContext) => CupertinoAlertDialog(
        title: Text(isError ? 'Error' : 'Info'),
        content: Text(message),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            child: const Text('Ok'),
            onPressed: () {
              Navigator.pop(dialogContext);
            },
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

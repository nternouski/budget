import 'package:flutter/material.dart';

class Display {
  static message(BuildContext context, String text, {int seconds = 2}) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        duration: Duration(seconds: seconds),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class ErrorData {
  String text;
  String? actionLabel;
  Function? actionCallback;

  ErrorData(this.text, this.actionLabel, this.actionCallback);
}

class HandlerError {
  final ValueNotifier<ErrorData?> _data = ValueNotifier<ErrorData?>(null);
  get notifier => _data;

  HandlerError._internal();
  static final HandlerError _singleton = HandlerError._internal();

  factory HandlerError() {
    return _singleton;
  }

  void setError(String text, {String? actionLabel, Function? actionCallback}) {
    _data.value = ErrorData(text, actionLabel, actionCallback);
    _data.notifyListeners();
  }

  showError(BuildContext context) {
    String? text = _data.value?.text;
    String? actionLabel = _data.value?.actionLabel;
    Function? actionCallback = _data.value?.actionCallback;

    if (text != null) {
      final theme = Theme.of(context);
      Color textColor = theme.colorScheme.onError;
      SnackBarAction? action;
      if (actionLabel != null && actionCallback != null) {
        action = SnackBarAction(label: actionLabel, textColor: textColor, onPressed: () => actionCallback());
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: theme.colorScheme.error,
          content: Text(text, style: TextStyle(color: textColor)),
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
          action: action,
        ),
      );
      _data.value = null;
    }
  }
}

class UserException implements Exception {
  String cause;
  UserException(this.cause);

  @override
  String toString() {
    return 'UserException: $cause';
  }
}

class LoginException implements Exception {
  String message;
  String code;
  LoginException(this.code, this.message);

  @override
  String toString() {
    return 'LoginException ($code): $message';
  }
}

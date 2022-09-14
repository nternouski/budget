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

class HandlerError {
  final ValueNotifier<String?> _textError = ValueNotifier<String?>(null);
  get notifier => _textError;

  HandlerError._internal();
  static final HandlerError _singleton = HandlerError._internal();

  factory HandlerError() {
    return _singleton;
  }

  void setError(String text) {
    _textError.value = text;
    _textError.notifyListeners();
  }

  showError(BuildContext context) {
    var text = _textError.value;
    if (text != null) {
      final theme = Theme.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: theme.colorScheme.error,
          content: Text(text, style: TextStyle(color: theme.colorScheme.onError)),
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
        ),
      );
      _textError.value = null;
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
  String cause;
  LoginException(this.cause);

  @override
  String toString() {
    return 'LoginException: $cause';
  }
}

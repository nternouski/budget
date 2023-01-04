import 'package:budget/common/preference.dart';
import 'package:budget/common/styles.dart';
import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode themeMode;
  final Preferences _preferences = Preferences();

  static const Color _primary = Colors.teal;
  static const Color _white = Colors.white;
  static const Color _black = Colors.black;
  static final Color _darkGrey = Colors.grey[900] ?? _black;

  static final light = ThemeData(
    primaryColor: _primary,
    backgroundColor: _primary,
    scaffoldBackgroundColor: _white,
    appBarTheme: const AppBarTheme(
      color: _white,
      iconTheme: IconThemeData(color: _black),
      elevation: 0,
      shadowColor: Colors.transparent,
    ),
    textTheme: const TextTheme(titleMedium: TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(textStyle: MaterialStateProperty.all(const TextStyle(fontSize: 16))),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(textStyle: MaterialStateProperty.all(const TextStyle(fontSize: 16))),
    ),
    colorScheme: const ColorScheme.light().copyWith(
      primary: _primary,
      onPrimary: _white,
      secondary: Colors.pink,
    ),
    popupMenuTheme: PopupMenuThemeData(shape: RoundedRectangleBorder(borderRadius: borderRadiusApp)),
    toggleableActiveColor: _primary,
    disabledColor: const Color.fromARGB(255, 145, 145, 145),
  );

  static final dark = ThemeData(
    primaryColor: _primary,
    backgroundColor: _primary,
    scaffoldBackgroundColor: _darkGrey,
    appBarTheme: AppBarTheme(
      color: _darkGrey,
      iconTheme: const IconThemeData(color: _white),
      elevation: 0,
      shadowColor: Colors.transparent,
    ),
    textTheme: const TextTheme(titleMedium: TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(textStyle: MaterialStateProperty.all(const TextStyle(fontSize: 16))),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(textStyle: MaterialStateProperty.all(const TextStyle(fontSize: 16))),
    ),
    colorScheme: const ColorScheme.dark().copyWith(
      primary: _primary,
      onPrimary: _white,
      secondary: Colors.pink[700],
      error: Colors.red[400],
      onError: _white,
    ),
    popupMenuTheme: PopupMenuThemeData(shape: RoundedRectangleBorder(borderRadius: borderRadiusApp)),
    toggleableActiveColor: _primary,
    disabledColor: Colors.grey[600],
  );

  ThemeProvider(this.themeMode);

  Future<void> swapTheme() async {
    if (themeMode == ThemeMode.dark) {
      themeMode = ThemeMode.light;
      await _preferences.setBool(PreferenceType.darkTheme, false);
    } else {
      themeMode = ThemeMode.dark;
      await _preferences.setBool(PreferenceType.darkTheme, true);
    }

    notifyListeners();
  }
}

enum ThemeTypes {
  primary,
  accent,
  warn,
}

class ButtonThemeStyle {
  static getStyle(ThemeTypes type, BuildContext context) {
    if (type == ThemeTypes.primary) {
      return ElevatedButton.styleFrom(
        onPrimary: Theme.of(context).colorScheme.onPrimary,
        primary: Theme.of(context).colorScheme.primary,
      ).copyWith(elevation: ButtonStyleButton.allOrNull(0.0));
    }
    if (type == ThemeTypes.accent) {
      return ElevatedButton.styleFrom(
        onPrimary: Theme.of(context).colorScheme.onSecondary,
        primary: Theme.of(context).colorScheme.secondary,
      ).copyWith(elevation: ButtonStyleButton.allOrNull(0.0));
    }
    if (type == ThemeTypes.warn) {
      return ElevatedButton.styleFrom(
        onPrimary: Theme.of(context).colorScheme.onError,
        primary: Theme.of(context).colorScheme.error,
      ).copyWith(elevation: ButtonStyleButton.allOrNull(0.0));
    }
  }
}

class Progress {
  static getLoadingProgress({required BuildContext context, double size = 45}) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 3,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

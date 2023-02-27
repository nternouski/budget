import 'package:flutter/material.dart';

import '../common/preference.dart';
import '../common/styles.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.system;
  final Preferences _preferences = Preferences();

  static const String? fontFamily = null;

  static const Color _primary = Colors.teal;

  static const _inputDecorator = InputDecorationTheme(
    contentPadding: EdgeInsets.all(10),
    labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
    hintStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
    prefixStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
    // floatingLabelBehavior: FloatingLabelBehavior.always,
    alignLabelWithHint: true,
    // fillColor: Colors.teal.withOpacity(0.2),
    // filled: true,
    // border: OutlineInputBorder(),
    // border: InputBorder.none,
  );

  static final light = ThemeData(
    useMaterial3: true,
    fontFamily: fontFamily,
    textTheme: const TextTheme(
      displayMedium: TextStyle(fontSize: 56.0, fontWeight: FontWeight.w400),
      headlineSmall: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w400),
      titleLarge: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500),
      titleMedium: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500),
      bodyMedium: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w400),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
        textStyle: MaterialStateProperty.all(const TextStyle(
          fontSize: 16,
          fontFamily: fontFamily,
          fontWeight: FontWeight.bold,
        )),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        textStyle: MaterialStateProperty.all(const TextStyle(fontSize: 16, fontFamily: fontFamily)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        textStyle: MaterialStateProperty.all(const TextStyle(fontSize: 16, fontFamily: fontFamily)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        side: MaterialStateProperty.all(borderOutlet.copyWith(color: _primary)),
        textStyle: MaterialStateProperty.all(const TextStyle(fontSize: 16, fontFamily: fontFamily)),
      ),
    ),
    cardTheme: const CardTheme(elevation: 0, color: Color(0xFFE3F6F4)),
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primary,
      primary: _primary,
      secondary: Colors.blue,
      brightness: Brightness.light,
    ),
    inputDecorationTheme: _inputDecorator,
  );

  static final dark = ThemeData(
    useMaterial3: true,
    fontFamily: fontFamily,
    textTheme: const TextTheme(
      displayMedium: TextStyle(fontSize: 56.0, fontWeight: FontWeight.w400),
      headlineSmall: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w400),
      titleLarge: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500),
      titleMedium: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500),
      bodyMedium: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w400),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
        textStyle: MaterialStateProperty.all(const TextStyle(
          fontSize: 16,
          fontFamily: fontFamily,
          fontWeight: FontWeight.bold,
        )),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        textStyle: MaterialStateProperty.all(const TextStyle(fontSize: 16, fontFamily: fontFamily)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        textStyle: MaterialStateProperty.all(const TextStyle(fontSize: 16, fontFamily: fontFamily)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        side: MaterialStateProperty.all(borderOutlet.copyWith(color: _primary)),
        textStyle: MaterialStateProperty.all(const TextStyle(fontSize: 16, fontFamily: fontFamily)),
      ),
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primary,
      primary: _primary,
      secondary: Colors.blue,
      error: Colors.red[400],
      brightness: Brightness.dark,
    ),
    inputDecorationTheme: _inputDecorator,
  );

  ThemeProvider() {
    _preferences.getBool(PreferenceType.darkTheme).then((darkTheme) {
      if (darkTheme == null) {
        themeMode = ThemeMode.system;
      } else {
        themeMode = darkTheme ? ThemeMode.dark : ThemeMode.light;
      }
      notifyListeners();
    });
  }

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

import 'package:budget/common/preference.dart';
import 'package:budget/common/styles.dart';
import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.system;
  final Preferences _preferences = Preferences();

  static const String? fontFamily = null;

  static const Color _primary = Colors.teal;
  static const Color _white = Colors.white;
  static const Color _black = Colors.black;
  static final Color _darkGrey = Colors.grey[900] ?? _black;

  static final light = ThemeData(
    fontFamily: fontFamily,
    primaryColor: _primary,
    scaffoldBackgroundColor: _white,
    appBarTheme: const AppBarTheme(
      color: _white,
      iconTheme: IconThemeData(color: _black),
      elevation: 0,
      shadowColor: Colors.transparent,
    ),
    textTheme: const TextTheme(
      displayMedium: TextStyle(fontSize: 56.0, fontWeight: FontWeight.w400, color: _black),
      headlineSmall: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w400, color: _black),
      titleLarge: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500, color: _black),
      titleMedium: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w500, color: _black),
      bodyLarge: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500, color: _black),
      bodyMedium: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w400, color: _black),
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
    colorScheme: const ColorScheme.light().copyWith(
      primary: _primary,
      onPrimary: _white,
      secondary: Colors.pink,
    ),
    popupMenuTheme: PopupMenuThemeData(shape: RoundedRectangleBorder(borderRadius: borderRadiusApp)),
    disabledColor: const Color.fromARGB(255, 145, 145, 145),
  );

  static final dark = ThemeData(
    fontFamily: fontFamily,
    primaryColor: _primary,
    scaffoldBackgroundColor: _darkGrey,
    appBarTheme: AppBarTheme(
      color: _darkGrey,
      iconTheme: const IconThemeData(color: _white),
      elevation: 0,
      shadowColor: Colors.transparent,
    ),
    textTheme: const TextTheme(
      displayMedium: TextStyle(fontSize: 56.0, fontWeight: FontWeight.w400, color: _white),
      headlineSmall: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w400, color: _white),
      titleLarge: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500, color: _white),
      titleMedium: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w500, color: _white),
      bodyLarge: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500, color: _white),
      bodyMedium: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w400, color: _white),
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
    colorScheme: const ColorScheme.dark().copyWith(
      primary: _primary,
      onPrimary: _white,
      secondary: Colors.pink[700],
      error: Colors.red[400],
      onError: _white,
    ),
    popupMenuTheme: PopupMenuThemeData(shape: RoundedRectangleBorder(borderRadius: borderRadiusApp)),
    disabledColor: Colors.grey[600],
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

class ButtonThemeStyle {
  static ButtonStyle? getStyle(ThemeTypes type, BuildContext context) {
    Color? foregroundColor;
    Color? backgroundColor;
    if (type == ThemeTypes.primary) {
      foregroundColor = Theme.of(context).colorScheme.onPrimary;
      backgroundColor = Theme.of(context).colorScheme.primary;
    }
    if (type == ThemeTypes.accent) {
      foregroundColor = Theme.of(context).colorScheme.onSecondary;
      backgroundColor = Theme.of(context).colorScheme.secondary;
    }
    if (type == ThemeTypes.warn) {
      foregroundColor = Theme.of(context).colorScheme.onError;
      backgroundColor = Theme.of(context).colorScheme.error;
    }
    return ElevatedButton.styleFrom(foregroundColor: foregroundColor, backgroundColor: backgroundColor, elevation: 0.0);
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

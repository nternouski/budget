import 'package:shared_preferences/shared_preferences.dart';

// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// const FlutterSecureStorage secureStorage = FlutterSecureStorage();

enum PreferenceType {
  darkTheme,
  periodStats,
  authLoginEnable,
  languageCode,
  predictionOnStats,
  dailyItemBalance,
  playlists,
}

extension ParseToString on PreferenceType {
  String toShortString() {
    return toString().split('.').last;
  }
}

class Preferences {
  static final Preferences _singleton = Preferences._internal();

  final _preferences = SharedPreferences.getInstance();

  factory Preferences() {
    return _singleton;
  }

  Future<bool> setString(PreferenceType key, String? value) async {
    var success = await (await _preferences).setString(key.toShortString(), value ?? '');
    // await secureStorage.write(key: 'refresh_token', value: result.refreshToken);
    // if (value == null || value == '') await secureStorage.delete(key: 'refresh_token');
    return success;
  }

  Future<String?> getString(PreferenceType key) async {
    return (await _preferences).getString(key.toShortString());
  }

  Future<bool> setBool(PreferenceType key, bool value) async {
    return (await _preferences).setBool(key.toShortString(), value);
  }

  Future<bool?> getBool(PreferenceType key) async {
    return (await _preferences).getBool(key.toShortString());
  }

  Future<bool> setInt(PreferenceType key, int value) async {
    return (await _preferences).setInt(key.toShortString(), value);
  }

  Future<int?> getInt(PreferenceType key) async {
    return (await _preferences).getInt(key.toShortString());
  }

  Preferences._internal();
}

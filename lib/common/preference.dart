import 'package:shared_preferences/shared_preferences.dart';

// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// const FlutterSecureStorage secureStorage = FlutterSecureStorage();

class Preferences {
  static final Preferences _singleton = Preferences._internal();

  final _preferences = SharedPreferences.getInstance();

  factory Preferences() {
    return _singleton;
  }

  Future<bool> set(String key, String? value) async {
    var success = await (await _preferences).setString(key, value ?? '');
    // await secureStorage.write(key: 'refresh_token', value: result.refreshToken);
    // if (value == null || value == '') await secureStorage.delete(key: 'refresh_token');
    return success;
  }

  Future<String?> get(String key) async {
    return (await _preferences).getString(key);
  }

  Preferences._internal();
}

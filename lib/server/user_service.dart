// ignore_for_file: non_constant_identifier_names, constant_identifier_names

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_appauth/flutter_appauth.dart';

import 'package:budget/common/styles.dart';
import '../model/currency.dart';
import '../server/model_rx.dart';
import '../model/user.dart';
import '../server/graphql_config.dart';
import '../common/preference.dart';

const FlutterAppAuth appAuth = FlutterAppAuth();

enum InitStatus { noUserStored, loginCompleted, errorOnLogin, inProgress }

class UserService extends UserRx {
  static const String AUTH0_DOMAIN = 'dev-cxwsnhav.us.auth0.com';
  static const String AUTH0_CLIENT_ID = '9IbiJ35L10DBCrZtVLPIUyXaDG7LsrmJ';
  static const String AUTH0_REDIRECT_URI = 'com.example.budget://login-callback';

  UserService._internal();
  static final UserService _singleton = UserService._internal();

  final preferences = Preferences();
  final token$ = BehaviorSubject<Token>();
  Stream<Token> get tokenRx => token$.stream;

  factory UserService() {
    return _singleton;
  }

  static Token _parseIdToken(String idToken) {
    final parts = idToken.split(r'.');
    assert(parts.length == 3);
    return Token.fromJson(idToken, jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1])))));
  }

  static Future<Map<String, dynamic>> _getUserDetails(String accessToken) async {
    Uri uri = Uri.https(AUTH0_DOMAIN, '/userinfo');
    final response = await http.get(uri, headers: {'Authorization': 'Bearer $accessToken'});

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get user details');
    }
  }

  Future<InitStatus> init(BuildContext context) async {
    try {
      String? storedRefreshToken = await preferences.getString(PreferenceType.refreshToken);
      if (storedRefreshToken == null || storedRefreshToken == '') return InitStatus.noUserStored;

      final response = await appAuth.token(TokenRequest(
        AUTH0_CLIENT_ID,
        AUTH0_REDIRECT_URI,
        issuer: 'https://$AUTH0_DOMAIN',
        refreshToken: storedRefreshToken,
      ));

      if (response != null) {
        if (response.refreshToken != null) {
          await preferences.setString(PreferenceType.refreshToken, response.refreshToken);
        }
        var token = _parseIdToken(response.idToken ?? '');
        token$.add(_parseIdToken(response.idToken ?? ''));
        if (token.picture == '' || token.email == '' || token.name == '') {
          final profile = await _getUserDetails(response.accessToken ?? '');
          token.picture = profile['picture'];
          token.email = profile['email'];
          token.name = profile['name'];
        }
        await graphQLConfig.setToken(token.idToken).then((value) => getCurrentUser(token, false, null));
      }
      return InitStatus.loginCompleted;
    } catch (e, s) {
      debugPrint(e.toString());
      debugPrint(s.toString());
      displayError(context, e.toString());
      return InitStatus.errorOnLogin;
    }
  }

  Future<void> singUp(BuildContext context, Currency? defaultCurrency) async {
    await login(context, defaultCurrency: defaultCurrency, singUp: true);
  }

  Future<void> login(BuildContext context, {Currency? defaultCurrency, bool singUp = false}) async {
    try {
      var result = await appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          AUTH0_CLIENT_ID,
          AUTH0_REDIRECT_URI,
          issuer: 'https://$AUTH0_DOMAIN',
          scopes: ['openid', 'profile', 'email', 'offline_access', 'api'],
          promptValues: ['login'],
        ),
      );

      if (result != null) {
        await preferences.setString(PreferenceType.refreshToken, result.refreshToken);
        var token = _parseIdToken(result.idToken ?? '');
        if (token.picture == '' || token.email == '' || token.name == '') {
          final profile = await _getUserDetails(result.accessToken ?? '');
          token.picture = profile['picture'];
          token.email = profile['email'];
          token.name = profile['name'];
        }
        await graphQLConfig.setToken(token.idToken).then(
          (value) {
            return getCurrentUser(token, singUp, defaultCurrency)
                .then((value) => token$.add(_parseIdToken(result.idToken ?? '')))
                .catchError((onError) {
              logout();
              debugPrint('-------------------------------------------');
              displayError(context, onError.message);
            });
          },
        );
      }
    } on PlatformException {
      displayError(context, 'User has Cancelled or no Internet');
    } catch (e, s) {
      debugPrint(e.toString());
      debugPrint(s.toString());
      displayError(context, e.toString());
    }
  }

  void logout() async {
    preferences.setString(PreferenceType.refreshToken, '');
    token$.add(Token.init());
    graphQLConfig.setToken('');
  }
}

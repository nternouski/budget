// ignore_for_file: non_constant_identifier_names, constant_identifier_names

import 'dart:convert';
import 'package:rxdart/rxdart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_appauth/flutter_appauth.dart';

import '../server/graphql_config.dart';
import '../common/color_constants.dart';
import '../common/preference.dart';
import '../model/user.dart';
import '../server/database.dart';

const FlutterAppAuth appAuth = FlutterAppAuth();

class Token {
  String idToken;
  String role;
  String userId;
  String name;
  String picture;
  String email;
  bool emailVerified;
  bool logged;

  Token({
    required this.idToken,
    required this.role,
    required this.userId,
    required this.name,
    required this.picture,
    required this.email,
    required this.emailVerified,
    required this.logged,
  });

  factory Token.fromJson(String idToken, Map<String, dynamic> json) {
    return Token(
      idToken: idToken,
      role: json['https://hasura.io/jwt/claims']['x-hasura-default-role'],
      userId: json['https://hasura.io/jwt/claims']['x-hasura-user-id'],
      name: json['name'] ?? '',
      picture: json['picture'] ?? '',
      email: json['email'] ?? '',
      emailVerified: json['email_verified'] ?? false,
      logged: true,
    );
  }

  factory Token.init() {
    return Token(
      idToken: '',
      role: '',
      userId: '',
      name: '',
      picture: '',
      email: '',
      emailVerified: false,
      logged: false,
    );
  }

  bool isLogged() => logged;
}

class UserService {
  static const String AUTH0_DOMAIN = 'dev-cxwsnhav.us.auth0.com';
  static const String AUTH0_CLIENT_ID = '9IbiJ35L10DBCrZtVLPIUyXaDG7LsrmJ';
  static const String AUTH0_REDIRECT_URI = 'com.example.budget://login-callback';
  static const String _refreshTokenKey = 'refresh_token';

  UserService._internal();
  static final UserService _singleton = UserService._internal();

  final userRx = Database(UserQueries(), 'users', User.fromJson);
  final preferences = Preferences();
  final behavior = BehaviorSubject<Token>();
  Stream<Token> get tokenRx => behavior.stream;

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

  Future<void> init(BuildContext context) async {
    behavior.add(Token.init());
    try {
      String? storedRefreshToken = await preferences.get(_refreshTokenKey);
      if (storedRefreshToken == null || storedRefreshToken == '') return;

      final response = await appAuth.token(TokenRequest(
        AUTH0_CLIENT_ID,
        AUTH0_REDIRECT_URI,
        issuer: 'https://$AUTH0_DOMAIN',
        refreshToken: storedRefreshToken,
      ));

      if (response != null) {
        await preferences.set(_refreshTokenKey, response.refreshToken);
        var token = _parseIdToken(response.idToken ?? '');
        behavior.add(_parseIdToken(response.idToken ?? ''));
        if (token.picture == '' || token.email == '' || token.name == '') {
          final profile = await _getUserDetails(response.accessToken ?? '');
          token.picture = profile['picture'];
          token.email = profile['email'];
          token.name = profile['name'];
        }
        graphQLConfig.setToken(token.idToken);
      }
    } catch (e, s) {
      print(s);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          backgroundColor: red,
        ),
      );
      logout();
    }
  }

  Future<void> login(BuildContext context) async {
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
        await preferences.set(_refreshTokenKey, result.refreshToken);
        var token = _parseIdToken(result.idToken ?? '');
        behavior.add(_parseIdToken(result.idToken ?? ''));
        if (token.picture == '' || token.email == '' || token.name == '') {
          final profile = await _getUserDetails(result.accessToken ?? '');
          token.picture = profile['picture'];
          token.email = profile['email'];
          token.name = profile['name'];
        }
        graphQLConfig.setToken(token.idToken);
      }
    } catch (e, s) {
      print(s);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          duration: const Duration(seconds: 15),
          behavior: SnackBarBehavior.floating,
          backgroundColor: red,
        ),
      );
    }
  }

  void logout() async {
    preferences.set(_refreshTokenKey, '');
    behavior.add(Token.init());
    graphQLConfig.setToken('');
  }
}

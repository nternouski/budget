// ignore_for_file: non_constant_identifier_names, constant_identifier_names
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

import '../i18n/index.dart';
import '../routes.dart';
import '../server/database/user_rx.dart';
import '../common/convert.dart';
import '../common/error_handler.dart';
import '../model/user.dart';
import '../model/currency.dart';

enum InitStatus { noUserStored, loginCompleted, errorOnLogin, inProgress }

enum AuthOption {
  email,
  google,
}

extension ParseToString on AuthOption {
  String toShortString() {
    return Convert.capitalize(toString().split('.').last);
  }
}

class UserService extends UserRx {
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final HandlerError handlerError = HandlerError();

  bool initStarted = false;

  UserService._internal();
  static final UserService _singleton = UserService._internal();

  Stream<auth.User?> get userAuth => _auth.authStateChanges();

  factory UserService() {
    return _singleton;
  }

  Future init(String id) async {
    try {
      if (!initStarted) await refreshUserData(id);
    } catch (e, s) {
      debugPrint(e.toString());
      debugPrint(s.toString());
      handlerError.setError(e.toString());
      logout();
    }
  }

  Future<void> singUp(
      BuildContext context, AuthOption option, String email, String password, Currency defaultCurrency) async {
    try {
      initStarted = true;

      auth.User? userAuth;
      try {
        if (option == AuthOption.google) {
          auth.GoogleAuthProvider googleAuth = auth.GoogleAuthProvider();
          auth.UserCredential result = await _auth.signInWithAuthProvider(googleAuth);
          userAuth = result.user;
        } else if (option == AuthOption.email) {
          auth.UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
          userAuth = result.user;
        }
      } catch (e) {
        dynamic error = e as dynamic;
        throw LoginException(error?.code, error?.message);
      }

      if (userAuth != null) {
        final user = User(
          id: userAuth.uid,
          createdAt: DateTime.now(),
          name: userAuth.displayName ?? 'Name Not Set'.i18n,
          email: userAuth.email ?? '',
          integrations: {},
          defaultCurrency: defaultCurrency,
        );

        await create(user);
        user$.add(user);
      }
    } on LoginException catch (e) {
      debugPrint('| ${e.code}: ${e.message}');
      handlerError.setError('${'User has Cancelled or no Internet on SignUp.'.i18n} ${e.message}');
    } catch (e, s) {
      debugPrint(e.toString());
      debugPrint(s.toString());
      handlerError.setError(e.toString());
      logout();
    }
  }

  Future<void> login(BuildContext context, AuthOption option, String email, String password,
      {Currency? defaultCurrency}) async {
    try {
      initStarted = true;
      auth.User? user;
      try {
        if (option == AuthOption.google) {
          auth.GoogleAuthProvider googleAuth = auth.GoogleAuthProvider();
          auth.UserCredential result = await _auth.signInWithAuthProvider(googleAuth);
          user = result.user;
        } else if (option == AuthOption.email) {
          auth.UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
          user = result.user;
        }
      } catch (e) {
        dynamic error = e as dynamic;
        throw LoginException(error?.code, error?.message);
      }
      if (user != null) {
        if (!user.emailVerified) {
          return RouteApp.redirect(context: context, url: URLS.emailVerification, fromScaffold: false);
        }
        await refreshUserData(user.uid);
      }
    } on LoginException catch (e) {
      debugPrint('| ${e.code}: ${e.message}');
      handlerError.setError('${'User has Cancelled or no Internet on Login.'.i18n} ${e.toString()}');
    } catch (e, s) {
      debugPrint(e.toString());
      debugPrint(s.toString());
      handlerError.setError(e.toString());
      logout();
    }
  }

  @override
  Future delete(String id) async {
    await db.deleteDoc(UserRx.collectionPath, id);
    auth.User? user = _auth.currentUser;
    if (user != null) await user.delete();
    return logout();
  }

  Future logout() async {
    try {
      initStarted = false;
      return await _auth.signOut();
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }
}

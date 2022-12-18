// ignore_for_file: non_constant_identifier_names, constant_identifier_names
import 'package:budget/model/user.dart';
import 'package:budget/server/database/user_rx.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

import '../common/error_handler.dart';
import '../model/currency.dart';

enum InitStatus { noUserStored, loginCompleted, errorOnLogin, inProgress }

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

  Future<void> singUp(BuildContext context, Currency defaultCurrency) async {
    try {
      initStarted = true;

      auth.User? userAuth;
      try {
        auth.GoogleAuthProvider googleAuth = auth.GoogleAuthProvider();
        auth.UserCredential result = await _auth.signInWithAuthProvider(googleAuth);
        userAuth = result.user;
      } catch (e) {
        throw LoginException(e.toString());
      }

      if (userAuth != null) {
        final user = User(
          id: userAuth.uid,
          createdAt: DateTime.now(),
          name: userAuth.displayName ?? 'Name Not Set',
          email: userAuth.email ?? '',
          integrations: {},
          defaultCurrency: defaultCurrency,
        );

        await create(user);
        user$.add(user);
      }
    } on LoginException catch (e) {
      handlerError.setError('User has Cancelled or no Internet on SignUp. ${e.toString()}');
    } catch (e, s) {
      debugPrint(e.toString());
      debugPrint(s.toString());
      handlerError.setError(e.toString());
      logout();
    }
  }

  Future<void> login(BuildContext context, {Currency? defaultCurrency}) async {
    try {
      initStarted = true;
      auth.User? user;
      try {
        auth.GoogleAuthProvider googleAuth = auth.GoogleAuthProvider();
        auth.UserCredential result = await _auth.signInWithAuthProvider(googleAuth);
        user = result.user;
      } catch (e) {
        throw LoginException(e.toString());
      }
      if (user != null) await refreshUserData(user.uid);
    } on LoginException catch (err) {
      handlerError.setError('User has Cancelled or no Internet on Login. ${err.toString()}');
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

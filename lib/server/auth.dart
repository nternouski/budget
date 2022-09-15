import 'dart:developer';

import 'package:budget/common/error_handler.dart';
import 'package:budget/common/preference.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';

import '../components/bottom_navigation_bar_widget.dart';
import '../screens/onboarding.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

enum LocalAuthState { nonSupported, success, error, inProgress, tryAgain }

class LocalAuthProvider extends ChangeNotifier {
  bool enable;
  final Preferences _preferences = Preferences();

  LocalAuthProvider(this.enable);

  static final LocalAuthentication _localAuth = LocalAuthentication();

  static Future<bool> authenticateIsAvailable() async {
    final isAvailable = await _localAuth.canCheckBiometrics;
    final isDeviceSupported = await _localAuth.isDeviceSupported();
    return isAvailable && isDeviceSupported;
  }

  Future<void> swapState() async {
    var available = await authenticateIsAvailable();
    if (available) {
      enable = !enable;
      await _preferences.setBool(PreferenceType.authLoginEnable, enable);
      notifyListeners();
    } else {
      await _preferences.setBool(PreferenceType.authLoginEnable, false);
    }
  }

  void tryAgain() {
    notifyListeners();
  }

  Future<LocalAuthState> authenticate() async {
    bool supported = await authenticateIsAvailable();
    if (!supported) return LocalAuthState.nonSupported;
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to show account balance',
        options: const AuthenticationOptions(stickyAuth: true, useErrorDialogs: false),
      );
      return authenticated ? LocalAuthState.success : LocalAuthState.tryAgain;
    } catch (e) {
      inspect(e);
      return (e as dynamic)['code'] == 'auth_in_progress' ? LocalAuthState.inProgress : LocalAuthState.error;
    }
  }
}

//=============================
//          AUTH WARP
//============================

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final HandlerError handlerError = HandlerError();
    handlerError.notifier.addListener(() {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) => handlerError.showError(context));
    });
    auth.User user = Provider.of<auth.User>(context);

    if (user != null) {
      userService.init(user.uid);
      final localAuth = Provider.of<LocalAuthProvider>(context);
      if (!localAuth.enable) return const BottomNavigationBarWidget();

      return FutureBuilder<LocalAuthState>(
        future: localAuth.authenticate(),
        builder: (BuildContext context, snapshot) {
          var status = snapshot.data;
          return status == LocalAuthState.success ? const BottomNavigationBarWidget() : AuthError(status: status);
        },
      );
    } else {
      return const OnBoarding();
    }
  }
}

class AuthError extends StatelessWidget {
  final LocalAuthState? status;
  const AuthError({Key? key, required this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localAuth = Provider.of<LocalAuthProvider>(context);
    String message = '';
    if (status == LocalAuthState.inProgress) message = 'Authentication In Progress.';
    if (status == LocalAuthState.nonSupported) message = 'Authentication Not Supported.';
    if (status == LocalAuthState.tryAgain) message = 'Error on authenticate with biometric.';

    return Scaffold(
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(message),
            if (status == LocalAuthState.tryAgain)
              ElevatedButton(onPressed: () => localAuth.tryAgain(), child: const Text('Try again!'))
          ],
        ),
      ),
    );
  }
}

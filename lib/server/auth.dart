import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

import '../i18n/index.dart';
import '../common/styles.dart';
import '../common/theme.dart';
import '../common/error_handler.dart';
import '../common/preference.dart';
import '../screens/email_verification_screen.dart';
import '../components/bottom_navigation_bar_widget.dart';
import '../screens/onboarding.dart';

enum LocalAuthState { nonSupported, success, error, inProgress, tryAgain }

extension ParseToString on LocalAuthState? {
  bool allow() {
    return this == LocalAuthState.success || this == LocalAuthState.nonSupported;
  }
}

class LocalAuthNotifier extends ChangeNotifier {
  bool enable;
  bool _available = false;
  final Preferences _preferences = Preferences();

  LocalAuthNotifier(this.enable) {
    Future.wait([authenticateIsAvailable()]).then((promise) {
      _available = promise[0];
    });
  }

  bool get available => _available;

  static final LocalAuthentication _localAuth = LocalAuthentication();

  Future<bool> authenticateIsAvailable() async {
    final isAvailable = await _localAuth.canCheckBiometrics;
    final isDeviceSupported = await _localAuth.isDeviceSupported();
    return isAvailable && isDeviceSupported;
  }

  Future<void> swapState() async {
    _available = await authenticateIsAvailable();
    if (_available) {
      enable = !enable;
      await _preferences.setBool(PreferenceType.authLoginEnable, enable);
    } else {
      await _preferences.setBool(PreferenceType.authLoginEnable, false);
    }
    notifyListeners();
  }

  void tryAgain() {
    notifyListeners();
  }

  Future<LocalAuthState> authenticate() async {
    bool supported = await authenticateIsAvailable();
    if (!supported) return LocalAuthState.nonSupported;
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to show account balance'.i18n,
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
      final emailVerification = Provider.of<EmailVerificationNotifier>(context);
      if (!emailVerification.isEmailVerified && !user.emailVerified) return const EmailVerificationScreen();

      final localAuth = Provider.of<LocalAuthNotifier>(context);
      return FutureBuilder<LocalAuthState>(
        future: localAuth.authenticate(),
        builder: (BuildContext context, snapshot) {
          var status = snapshot.data;
          return status.allow() ? const BottomNavigationBarWidget() : AuthError(status: status);
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
    final ThemeData theme = Theme.of(context);

    final localAuth = Provider.of<LocalAuthNotifier>(context);
    String message = 'Confirm fingerprint to continue.'.i18n;
    if (status == LocalAuthState.inProgress) message = 'Authentication In Progress.'.i18n;
    if (status == LocalAuthState.nonSupported) message = 'Authentication Not Supported.'.i18n;
    if (status == LocalAuthState.tryAgain) message = 'Error on authenticate with biometric.'.i18n;

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          const SizedBox(height: 200),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(color: theme.cardColor),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Fingerprint Unlock'.i18n, style: theme.textTheme.titleLarge),
                      const SizedBox(height: 20),
                      InkWell(
                        onTap: () => localAuth.tryAgain(),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.fingerprint, size: 35),
                            const SizedBox(width: 15),
                            Text('Touch Sensor'.i18n)
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(message),
                      if (status == LocalAuthState.tryAgain || status == LocalAuthState.nonSupported)
                        const SizedBox(height: 10),
                      if (status == LocalAuthState.nonSupported)
                        ElevatedButton(
                          style: ButtonThemeStyle.getStyle(ThemeTypes.warn, context),
                          onPressed: () => localAuth.swapState(),
                          child: Text('Disable Fingerprint'.i18n),
                        ),
                      if (status == LocalAuthState.tryAgain)
                        ElevatedButton(child: Text('Try again!'.i18n), onPressed: () => localAuth.tryAgain())
                    ],
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}

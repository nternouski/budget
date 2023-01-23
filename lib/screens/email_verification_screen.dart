import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../i18n/index.dart';
import '../common/error_handler.dart';
import '../server/user_service.dart';

class EmailVerificationNotifier extends ChangeNotifier {
  bool isEmailVerified = false;

  update(bool newValue) {
    if (newValue != isEmailVerified) {
      isEmailVerified = newValue;
      notifyListeners();
    }
  }
}

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({Key? key}) : super(key: key);

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  UserService userService = UserService();
  Timer? timer;

  @override
  void initState() {
    super.initState();
    auth.FirebaseAuth.instance.currentUser?.sendEmailVerification();
    timer = Timer.periodic(const Duration(seconds: 3), (_) => checkEmailVerified());
  }

  checkEmailVerified() async {
    var instance = auth.FirebaseAuth.instance;
    if (instance.currentUser == null) {
      timer?.cancel();
      return userService.logout();
    }
    await instance.currentUser?.reload();
    var emailVerification = Provider.of<EmailVerificationNotifier>(context, listen: false);
    bool check = instance.currentUser!.emailVerified;
    if (check) {
      setState(() {
        Display.message(context, 'Email Successfully Verified'.i18n);
        timer?.cancel();
        emailVerification.update(check);
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unnecessary_cast
    final user = Provider.of<auth.User>(context) as auth.User?;
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        titleTextStyle: theme.textTheme.titleLarge,
        leading: IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              userService.logout();
              Display.message(context, 'Logout successfully!'.i18n);
            }),
        title: Text('Email Verification'.i18n),
      ),
      body: Column(children: [
        const SizedBox(height: 70),
        Center(child: Text('Check your Email'.i18n, textAlign: TextAlign.center)),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Center(
            child: Text('We have sent you a Email on %s'.fill([user?.email ?? '']), textAlign: TextAlign.center),
          ),
        ),
        const SizedBox(height: 20),
        const Center(child: CircularProgressIndicator()),
        const SizedBox(height: 20),
        Center(child: Text('Verifying email..'.i18n, textAlign: TextAlign.center)),
        const SizedBox(height: 30),
        ElevatedButton(
          child: Text('Resend'.i18n),
          onPressed: () {
            try {
              auth.FirebaseAuth.instance.currentUser?.sendEmailVerification();
            } catch (e) {
              debugPrint('$e');
            }
          },
        ),
      ]),
    );
  }
}

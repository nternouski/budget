import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/user.dart';
import '../server/user_service.dart';

/// -----------------------------------
///                 UserLogin
/// -----------------------------------

class UserLogin extends StatefulWidget {
  const UserLogin({Key? key}) : super(key: key);

  @override
  UserLoginState createState() => UserLoginState();
}

/// -----------------------------------
///              UserLogin State
/// -----------------------------------

class UserLoginState extends State<UserLogin> {
  bool isBusy = false;
  UserService userService = UserService();

  @override
  Widget build(BuildContext context) {
    if (isBusy) {
      final primary = Theme.of(context).colorScheme.primary;
      return SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 3, color: primary));
    } else {
      return Consumer<Token>(
        builder: (context, token, child) => token.isLogged() ? buildProfile(token) : buildLogin(),
      );
    }
  }

  Widget buildProfile(Token token) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(fit: BoxFit.fill, image: NetworkImage(token.picture)),
          ),
        ),
      ],
    );
  }

  Widget buildLogin() {
    return TextButton(child: const Text('Login'), onPressed: () => loginAction());
  }

  Future<void> loginAction() async {
    setState(() => isBusy = true);
    await userService.login(context);
    setState(() => isBusy = false);
  }
}

import 'package:budget/server/user_service.dart';
import 'package:flutter/material.dart';

import '../common/color_constants.dart';

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
      return const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 3, color: primary));
    } else {
      return Center(
          child: StreamBuilder<Token>(
        stream: userService.tokenRx,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            final token = snapshot.data;
            return token != null && token.isLogged() ? buildProfile(token) : buildLogin();
          } else if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          } else {
            return const Text('Error login');
          }
        },
      ));
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

  @override
  void initState() {
    userService.init(context);
    super.initState();
  }
}

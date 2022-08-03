import 'package:budget/common/styles.dart';
import 'package:budget/components/user_login.dart';
import 'package:budget/model/user.dart';
import 'package:budget/server/user_service.dart';
import 'package:flutter/material.dart';
import '../common/color_constants.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfileScreen> {
  final smallPadding = const SizedBox(height: 10);
  final bigPadding = const SizedBox(height: 20);

  UserService userService = UserService();
  User user = User(
    id: '',
    createdAt: DateTime(2022),
    name: 'Sebas',
    email: 'nahuelternouski@gmail.com',
    defaultCurrencyId: '',
  );

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController(text: 'abbie_wilson@gmail.com');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: getBody(),
    );
  }

  Widget getBody() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: const BoxDecoration(color: white),
            child: Padding(
              padding: const EdgeInsets.only(top: 70, right: 20, left: 20, bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Profile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: black)),
                  UserLogin()
                ],
              ),
            ),
          ),
          bigPadding,
          StreamBuilder<User>(
            stream: Stream.value(user),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var user = snapshot.data;
                if (user != null) return getForm();
              }
              return UserLogin();
            },
          ),
        ],
      ),
    );
  }

  Widget buildName() {
    return TextFormField(
      initialValue: user.name,
      decoration: InputStyle.inputDecoration(labelTextStr: 'Name', hintTextStr: 'Cookies'),
      validator: (String? value) {
        if (value!.isEmpty) return 'Name is Required.';
        return null;
      },
      onSaved: (String? value) {
        user.name = value!;
      },
    );
  }

  Widget getForm() {
    return Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Column(children: <Widget>[
            buildName(),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  buttonCancelContext(context),
                  ElevatedButton(
                    onPressed: () {
                      if (!_formKey.currentState!.validate()) return;
                      _formKey.currentState!.save();
                      userService.userRx.update(user);
                      Navigator.of(context).pop();
                    },
                    child: const Text('Update', style: TextStyle(fontSize: 17)),
                  )
                ],
              ),
            )
          ]),
        ));
  }
}

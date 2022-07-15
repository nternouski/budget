import 'package:flutter/material.dart';
import '../common/color_constants.dart';

class Profile {
  String name;
  String email;

  Profile(this.name, this.email);
}

class ProfileScreen extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfileScreen> {
  var profile = Profile("Sebastian Nahuel", "nahuelternouski@gmail.com");

  final smallPadding = const SizedBox(height: 10);
  final bigPadding = const SizedBox(height: 20);

  TextEditingController _email = TextEditingController(text: "abbie_wilson@gmail.com");
  TextEditingController dateOfBirth = TextEditingController(text: "04-19-1992");
  TextEditingController password = TextEditingController(text: "123456");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: getBody(),
    );
  }

  Widget getBody() {
    var size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(color: white, boxShadow: [
              BoxShadow(color: grey.withOpacity(0.01), spreadRadius: 10, blurRadius: 3),
            ]),
            child: Padding(
              padding: const EdgeInsets.only(top: 60, right: 20, left: 20, bottom: 25),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text("Profile", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: black)),
                      Icon(Icons.settings_outlined)
                    ],
                  ),
                  bigPadding,
                  Row(
                    children: [
                      Container(
                        width: (size.width - 40) * 0.6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile.name,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: black),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  bigPadding,
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(color: primary, borderRadius: BorderRadius.circular(12), boxShadow: [
                      BoxShadow(
                        color: primary.withOpacity(0.01),
                        spreadRadius: 10,
                        blurRadius: 3,
                      ),
                    ]),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20, top: 25, bottom: 25),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "United Bank Asia",
                                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12, color: white),
                              ),
                              smallPadding,
                              Text(
                                "\$2446.90",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: white),
                              ),
                            ],
                          ),
                          Container(
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: white)),
                            child: Padding(
                              padding: const EdgeInsets.all(13.0),
                              child: Text(
                                "Update",
                                style: TextStyle(color: white),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          bigPadding,
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Email",
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: Color(0xff67727d)),
                ),
                TextField(
                  controller: _email,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: black),
                  decoration: InputDecoration(
                    hintText: "Email",
                  ),
                ),
                bigPadding,
                Text(
                  "Date of birth",
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: Color(0xff67727d)),
                ),
                TextField(
                  controller: dateOfBirth,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: black),
                  decoration: InputDecoration(
                    hintText: "Date of birth",
                  ),
                ),
                bigPadding,
                Text(
                  "Date of birth",
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: Color(0xff67727d)),
                ),
                TextField(
                  obscureText: true,
                  controller: password,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: black),
                  decoration: InputDecoration(
                    hintText: "Password",
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

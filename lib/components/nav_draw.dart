import 'package:budget/server/user_service.dart';
import 'package:flutter/material.dart';
import '../common/color_constants.dart';
import '../routes.dart';

class NavDrawer extends StatelessWidget {
  UserService userService = UserService();

  NavDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: primary.withOpacity(0.7),
              image: const DecorationImage(fit: BoxFit.scaleDown, image: AssetImage('assets/images/auto.png')),
            ),
            child: const Text('Budget app', style: TextStyle(color: Colors.white, fontSize: 25)),
          ),
          ListTile(
            leading: const Icon(Icons.input),
            title: const Text('Welcome'),
            onTap: () => {},
          ),
          ListTile(
            leading: const Icon(Icons.phonelink_setup),
            title: const Text('Mobile Calculator'),
            onTap: () => RouteApp.redirect(context: context, url: URLS.mobileCalculator),
          ),
          ListTile(
            leading: const Icon(Icons.query_stats),
            title: const Text('Stats'),
            onTap: () => RouteApp.redirect(context: context, url: URLS.stats),
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Logout'),
            onTap: () {
              userService.logout();
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            onTap: () {
              Navigator.of(context).pop();
              showAboutDialog(
                context: context,
                applicationIcon: const FlutterLogo(),
                applicationName: 'Budget',
                applicationVersion: '0.0.1',
                applicationLegalese: '©2022 budget',
                children: [
                  const Padding(
                      padding: EdgeInsets.only(top: 15),
                      child: Text('This app is created by Sebstian Nahuel Ternouski'))
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

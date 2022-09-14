import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

import '../server/user_service.dart';
import '../routes.dart';

class NavDrawer extends StatelessWidget {
  final nameLimit = 25;
  final emailLimit = 30;

  final UserService userService = UserService();

  NavDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            margin: EdgeInsets.zero,
            padding: EdgeInsets.zero,
            child: Consumer<auth.User?>(
              builder: (context, user, child) => user != null ? buildProfile(theme, user) : const Text('ERROR!'),
            ),
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
            leading: const Icon(Icons.wallet),
            title: const Text('Wise Sync'),
            onTap: () => RouteApp.redirect(context: context, url: URLS.wiseSync),
          ),
          ListTile(
            leading: const Icon(Icons.quiz),
            title: const Text('FAQ'),
            onTap: () => RouteApp.redirect(context: context, url: URLS.faq),
          ),
          const Divider(thickness: 1),
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
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Column(children: const [
                      Text('This app is created by Sebastian Nahuel Ternouski'),
                      SizedBox(height: 20),
                      Text('Special thanks to "stories" on freepik.'),
                      Text('https://www.freepik.com/author/stories'),
                    ]),
                  )
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget buildProfile(ThemeData theme, auth.User user) {
    var name = user.displayName ?? 'Name Not Set';
    var email = user.email ?? 'No Email';
    var photoURL = user.photoURL;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: photoURL != null ? DecorationImage(fit: BoxFit.fill, image: NetworkImage(photoURL)) : null,
          ),
        ),
        const SizedBox(height: 15),
        Text(name.length > nameLimit ? '${name.substring(0, nameLimit)}..' : name, style: theme.textTheme.titleLarge),
        const SizedBox(height: 5),
        Text(email.length > emailLimit ? '${email.substring(0, emailLimit)}..' : email),
      ],
    );
  }
}

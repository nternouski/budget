import 'package:budget/common/classes.dart';
import 'package:budget/common/version_checker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

import '../i18n/index.dart';
import '../server/user_service.dart';
import '../model/user.dart';
import '../routes.dart';

class NavDrawer extends StatelessWidget {
  final nameLimit = 25;
  final emailLimit = 30;

  final UserService userService = UserService();

  NavDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // ignore: unnecessary_cast
    var dbUser = Provider.of<User>(context) as User?;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            margin: EdgeInsets.zero,
            padding: EdgeInsets.zero,
            child: Consumer<auth.User?>(
              builder: (context, user, child) =>
                  user != null ? buildProfile(theme, user, dbUser) : const Text('ERROR!'),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.phonelink_setup),
            title: Text('Mobile Calculator'.i18n),
            onTap: () => RouteApp.redirect(context: context, url: URLS.mobileCalculator),
          ),
          ListTile(
            leading: const Icon(Icons.query_stats),
            title: Text('Stats'.i18n),
            onTap: () => RouteApp.redirect(context: context, url: URLS.stats),
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: Text('Expense Simulation'.i18n),
            onTap: () => RouteApp.redirect(context: context, url: URLS.expensePrediction),
          ),
          ListTile(
            leading: const Icon(Icons.wallet),
            title: Text('Wise Sync'.i18n),
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
            title: Text('Logout'.i18n),
            onTap: () {
              userService.logout();
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: Text('About'.i18n),
            onTap: () async {
              final status = await AppVersionChecker().getStatus();
              Navigator.of(context).pop();
              AboutDialogClass.show(context, additionalInfo: '${'Stable version'.i18n} ${status.newVersion}. ');
            },
          ),
        ],
      ),
    );
  }

  Widget buildProfile(ThemeData theme, auth.User user, User? dbUser) {
    var name = dbUser != null && dbUser.name != '' ? dbUser.name : user.displayName ?? 'Name Not Set'.i18n;
    var email = user.email ?? '';
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

import '../i18n/index.dart';
import '../components/about_dialog.dart' as app;
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
          if (dbUser != null && dbUser.superUser)
            ListTile(
              leading: const Icon(Icons.youtube_searched_for),
              title: Text('Playlist Listener'.i18n),
              onTap: () => RouteApp.redirect(context: context, url: URLS.playlistListenerScreen),
            ),
          ListTile(
            leading: const Icon(Icons.local_grocery_store_rounded),
            title: Text('Expense Simulation'.i18n),
            onTap: () => RouteApp.redirect(context: context, url: URLS.expensePrediction),
          ),
          ListTile(
            leading: const Icon(Icons.query_stats),
            title: Text('Statistics'.i18n),
            onTap: () => RouteApp.redirect(context: context, url: URLS.stats),
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
              Navigator.of(context).pop();
              app.AboutDialog.show(context);
            },
          ),
        ],
      ),
    );
  }

  Widget buildProfile(ThemeData theme, auth.User user, User? dbUser) {
    var name = dbUser != null && dbUser.name != '' ? dbUser.name : user.displayName ?? 'Name Not Set'.i18n;
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
        Text(name.length > nameLimit ? '${name.substring(0, nameLimit)}..' : name, style: theme.textTheme.titleMedium),
      ],
    );
  }
}

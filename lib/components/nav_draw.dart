import 'package:budget/model/user.dart';
import 'package:budget/server/user_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../routes.dart';

class NavDrawer extends StatelessWidget {
  final nameLimit = 20;

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
            child: Consumer<Token>(
              builder: (context, token, child) => token.isLogged() ? buildProfile(theme, token) : const Text('ERROR!'),
            ),
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

  Widget buildProfile(ThemeData theme, Token token) {
    var nameExceded = token.name.length > nameLimit;
    var name = nameExceded ? '${token.name.substring(0, nameLimit)}..' : token.name;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(fit: BoxFit.fill, image: NetworkImage(token.picture)),
          ),
        ),
        const SizedBox(width: 20),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: theme.textTheme.titleLarge),
            const SizedBox(height: 5),
            Text(token.email),
          ],
        )
      ],
    );
  }
}

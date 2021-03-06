import 'package:flutter/material.dart';
import '../common/color_constants.dart';
import '../routes.dart';

class NavDrawer extends StatelessWidget {
  const NavDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String name = "Sebastian";
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: primary.withOpacity(0.7),
              image: const DecorationImage(fit: BoxFit.scaleDown, image: AssetImage('assets/images/auto.png')),
            ),
            child: Text(name, style: const TextStyle(color: Colors.white, fontSize: 25)),
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
            onTap: () => {Navigator.of(context).pop()},
          ),
        ],
      ),
    );
  }
}

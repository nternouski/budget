import 'package:budget/common/styles.dart';
import 'package:budget/common/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';

import '../server/user_service.dart';
import '../model/user.dart';
import '../components/update_user.dart';
import '../components/user_login.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

const SizedBox spacing = SizedBox(height: 20);
UserService userService = UserService();

class SettingsScreenState extends State<SettingsScreen> {
  final int textLimit = 22;
  SizedBox heightSeparation = const SizedBox(height: 12);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: getBody(context),
      ),
    );
  }

  SettingsSection getProfile(User user) {
    var emailExceded = user.email.length > textLimit;
    var nameExceded = user.name.length > textLimit;
    var email = emailExceded ? '${user.email.substring(0, textLimit)}..' : user.email;
    var name = nameExceded ? '${user.name.substring(0, textLimit)}..' : user.name;

    return SettingsSection(
      title: const Text('Profile', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
      tiles: [
        SettingsTile.navigation(
          leading: const Icon(Icons.person),
          title: const Text('Name'),
          value: Text(name),
          trailing: UpdateUser(user: user, onUpdate: (user) => setState(() {})),
        ),
        SettingsTile.navigation(
          leading: const Icon(Icons.email),
          title: const Text('Email'),
          value: Text(email),
          trailing: UpdateUser(user: user, onUpdate: (user) => setState(() {})),
        ),
        SettingsTile.navigation(
          leading: const Icon(Icons.currency_exchange),
          title: const Text('Default Currency'),
          value: Text(user.defaultCurrency != null ? user.defaultCurrency!.symbol : 'No set yet'),
          trailing: UpdateUser(user: user, onUpdate: (user) => setState(() {})),
        ),
      ],
    );
  }

  SettingsSection getCommon(ThemeData themeData) {
    final theme = Provider.of<ThemeProvider>(context);
    return SettingsSection(
        title: const Text('Common', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
        tiles: [
          SettingsTile.navigation(
              leading: const Icon(Icons.language), title: const Text('Language'), value: const Text('English')),
          SettingsTile.navigation(
              leading: const Icon(Icons.language), title: const Text('Language'), value: const Text('English')),
          SettingsTile.navigation(
              leading: const Icon(Icons.query_stats),
              title: const Text('Period of Stats'),
              value: const Text('1 Month')),
          SettingsTile.switchTile(
            onToggle: (value) => theme.swapTheme(),
            initialValue: theme.themeMode == ThemeMode.dark,
            leading: const Icon(Icons.brightness_auto),
            activeSwitchColor: themeData.colorScheme.primary,
            title: const Text('Dark Theme'),
          )
        ]);
  }

  List<Widget> getBody(BuildContext context) {
    final theme = Theme.of(context);
    User? user = Provider.of<User>(context);
    return [
      SliverAppBar(
        titleTextStyle: theme.textTheme.titleLarge,
        pinned: true,
        leading: getLadingButton(context),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [Text('Settings'), UserLogin()],
        ),
      ),
      SliverToBoxAdapter(
        child: SettingsList(
          shrinkWrap: true,
          contentPadding: const EdgeInsets.only(left: 20, right: 20),
          physics: const BouncingScrollPhysics(),
          lightTheme: SettingsThemeData(
            settingsListBackground: theme.scaffoldBackgroundColor,
            titleTextColor: theme.colorScheme.primary,
          ),
          sections: user == null ? [] : [getProfile(user), getCommon(theme), DangerZone(user: user)],
        ),
      ),
    ];
  }
}

class DangerZone extends AbstractSettingsSection {
  final User user;
  static TextEditingController confirmController = TextEditingController(text: '');
  static const String _checkValue = 'confirm';

  const DangerZone({Key? key, required this.user}) : super(key: key);

  Future<bool?> _confirm(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Please Write Confirm, to delete permanently your user'),
          content: TextFormField(
            controller: confirmController,
            decoration: InputStyle.inputDecoration(labelTextStr: '', hintTextStr: 'Confirm'),
          ),
          actions: <Widget>[
            buttonCancelContext(context),
            ElevatedButton(
              style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.red)),
              child: const Text('Delete', style: TextStyle(fontSize: 17)),
              onPressed: () {
                if (confirmController.text == _checkValue) {
                  confirmController.text = '';
                  Navigator.pop(context, true);
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        const Divider(),
        spacing,
        Text('Danger Zone', style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.error)),
        spacing,
        ElevatedButton(
          style: ButtonThemeStyle.getStyle(ThemeTypes.warn, context),
          onPressed: () async {
            if (await _confirm(context) == true) {
              await userService.delete(user.id);
              userService.logout();
            }
          },
          child: const Text('DELETE USER', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        spacing,
      ],
    );
  }
}

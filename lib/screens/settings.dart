import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';

import '../components/profile_settings.dart';
import '../components/current_rates_settings.dart';
import '../common/period_stats.dart';
import '../common/styles.dart';
import '../common/theme.dart';
import '../components/update_or_create_integration.dart';
import '../server/user_service.dart';
import '../model/user.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

const SizedBox spacing = SizedBox(height: 20);
UserService userService = UserService();

class SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: getBody(context),
      ),
    );
  }

  _bottomSheetPeriodStats(PeriodStats periodStats) {
    return SingleChildScrollView(
        child: Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Padding(
        padding: const EdgeInsets.only(top: 30, bottom: 10, left: 20, right: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Period of Time', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.info_outline),
                SizedBox(width: 5),
                Text('That will affect the budget and stats')
              ],
            ),
            const SizedBox(height: 10),
            ...Periods.options.map(
              (option) => CheckboxListTile(
                title: Text(option.humanize),
                value: option.days == periodStats.days,
                onChanged: (check) {
                  periods.update(option.days);
                  Navigator.pop(context);
                },
                selected: false,
              ),
            ),
          ],
        ),
      ),
    ));
  }

  SettingsSection getCommon(ThemeData themeData, PeriodStats periodStats) {
    final theme = Provider.of<ThemeProvider>(context);

    return SettingsSection(
        title: const Text('Common', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
        tiles: [
          SettingsTile.navigation(
              leading: const Icon(Icons.language), title: const Text('Language'), value: const Text('English')),
          SettingsTile.navigation(
            leading: const Icon(Icons.query_stats),
            title: const Text('Period of Analytics'),
            value: Text(periodStats.humanize),
            onPressed: (context) => showModalBottomSheet(
              enableDrag: true,
              context: context,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: radiusApp)),
              clipBehavior: Clip.antiAliasWithSaveLayer,
              builder: (BuildContext context) => BottomSheet(
                enableDrag: false,
                onClosing: () {},
                builder: (BuildContext context) => _bottomSheetPeriodStats(periodStats),
              ),
            ),
          ),
          SettingsTile.switchTile(
            onToggle: (value) => theme.swapTheme(),
            initialValue: theme.themeMode == ThemeMode.dark,
            leading: const Icon(Icons.brightness_auto),
            activeSwitchColor: themeData.colorScheme.primary,
            title: const Text('Dark Theme'),
          )
        ]);
  }

  SettingsSection getIntegration() {
    return SettingsSection(
      title: const Text('Integrations ', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
      tiles: [
        SettingsTile.navigation(
          leading: const Icon(Icons.wallet),
          title: const Text('Wise'),
          trailing: const UpdateOrCreateIntegration(),
        ),
      ],
    );
  }

  List<Widget> getBody(BuildContext context) {
    final theme = Theme.of(context);
    User? user = Provider.of<User>(context);

    return [
      SliverAppBar(
        titleTextStyle: theme.textTheme.titleLarge,
        pinned: true,
        leading: getLadingButton(context),
        title: const Text('Settings'),
      ),
      SliverToBoxAdapter(
        child: ValueListenableBuilder<PeriodStats>(
          valueListenable: periods.selected,
          builder: (context, periodStats, child) {
            List<AbstractSettingsSection> sections = [];
            if (user != null) {
              sections = [
                ProfileSettings(user: user),
                getCommon(theme, periodStats),
                getIntegration(),
                CurrentRatesSettings(user: user),
                DangerZone(userId: user.id),
              ];
            }
            return SettingsList(
              shrinkWrap: true,
              contentPadding: const EdgeInsets.only(left: 20, right: 20),
              physics: const BouncingScrollPhysics(),
              lightTheme: SettingsThemeData(
                settingsListBackground: theme.scaffoldBackgroundColor,
                titleTextColor: theme.colorScheme.primary,
              ),
              darkTheme: SettingsThemeData(
                settingsListBackground: theme.scaffoldBackgroundColor,
                titleTextColor: theme.colorScheme.primary,
              ),
              sections: sections,
            );
          },
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 80))
    ];
  }
}

class DangerZone extends AbstractSettingsSection {
  final String userId;

  const DangerZone({Key? key, required this.userId}) : super(key: key);

  Future<bool?> _confirm(BuildContext context, String confirmationString) {
    TextEditingController confirmController = TextEditingController(text: '');
    ValueNotifier<bool> buttonEnabled = ValueNotifier(false);
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Please write \'$confirmationString\'..'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('To delete permanently your user and all the data related to you.'),
            TextFormField(
              controller: confirmController,
              decoration: InputStyle.inputDecoration(labelTextStr: '', hintTextStr: confirmationString),
              onChanged: (input) => buttonEnabled.value = confirmController.text == confirmationString,
            ),
          ]),
          actions: <Widget>[
            buttonCancelContext(context),
            ValueListenableBuilder(
              valueListenable: buttonEnabled,
              builder: (BuildContext context, bool enabled, _) => ElevatedButton(
                style: ButtonThemeStyle.getStyle(ThemeTypes.warn, context),
                onPressed: enabled ? () => Navigator.pop(context, true) : null,
                child: const Text('Delete'),
              ),
            )
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
        const Divider(thickness: 1.5),
        spacing,
        Text('Danger Zone', style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.error)),
        spacing,
        ElevatedButton(
          style: ButtonThemeStyle.getStyle(ThemeTypes.warn, context),
          onPressed: () async {
            if (await _confirm(context, 'delete') == true) await userService.delete(userId);
          },
          child: const Text('DELETE USER'),
        ),
        spacing,
      ],
    );
  }
}

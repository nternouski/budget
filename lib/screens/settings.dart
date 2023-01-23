import 'dart:ui' as ui;
import 'package:budget/common/classes.dart';
import 'package:budget/common/preference.dart';
import 'package:flutter/material.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';

import '../i18n/index.dart';
import '../server/auth.dart';
import '../components/profile_settings.dart';
import '../components/current_rates_settings.dart';
import '../common/period_stats.dart';
import '../common/styles.dart';
import '../common/theme.dart';
import '../server/user_service.dart';
import '../model/user.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

const SizedBox spacing = SizedBox(height: 20);
final UserService userService = UserService();

class LocaleOption {
  final String title;
  final Locale? locale;

  const LocaleOption({required this.title, this.locale});
}

class SettingsScreenState extends State<SettingsScreen> {
  final _titleStyle = const TextStyle(fontSize: 17, fontWeight: FontWeight.w500);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    User? user = Provider.of<User>(context);

    return Scaffold(
      body: CustomScrollView(physics: const BouncingScrollPhysics(), slivers: [
        SliverAppBar(
          titleTextStyle: theme.textTheme.titleLarge,
          pinned: true,
          leading: getLadingButton(context),
          title: Text('Settings'.i18n),
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
                  getIntegration(user),
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
        const SliverToBoxAdapter(child: SizedBox(height: 100))
      ]),
    );
  }

  _bottomSheetPeriodStats(PeriodStats periodStats, BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
        child: Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Padding(
        padding: const EdgeInsets.only(top: 30, bottom: 10, left: 20, right: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Period of Time'.i18n, style: theme.textTheme.titleLarge),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.info_outline),
                const SizedBox(width: 5),
                Text('That will affect the graphics and stats'.i18n)
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

  _bottomSheetLanguage(BuildContext context, String languageCode) {
    final theme = Theme.of(context);
    final langNotifier = Provider.of<LanguageNotifier>(context);

    return SingleChildScrollView(
        child: Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Padding(
        padding: const EdgeInsets.only(top: 30, bottom: 10, left: 20, right: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Choose Language'.i18n, style: theme.textTheme.titleLarge),
            const SizedBox(height: 10),
            ...[
              LocaleOption(title: 'System'.i18n),
              const LocaleOption(title: 'Español', locale: Locale('es')),
              const LocaleOption(title: 'English', locale: Locale('en')),
            ].map(
              (option) => ListTile(
                title: Text(option.title),
                onTap: () {
                  final locale = option.locale ?? ui.window.locale;
                  I18n.of(context).locale = locale;
                  langNotifier.setLocale(locale);

                  final String languageCode =
                      option.locale != null ? Intl.shortLocale(option.locale!.languageCode) : '';
                  Preferences().setString(PreferenceType.languageCode, languageCode);

                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    ));
  }

  SettingsSection getCommon(ThemeData themeData, PeriodStats periodStats) {
    final theme = Provider.of<ThemeProvider>(context);
    final localAuth = Provider.of<LocalAuthProvider>(context);
    final languageCode = I18n.of(context).locale.languageCode;

    return SettingsSection(title: Text('Common'.i18n, style: _titleStyle), tiles: [
      SettingsTile.navigation(
        leading: const Icon(Icons.language),
        title: Text('Language'.i18n),
        value: Text(languageCode.toUpperCase()),
        onPressed: (context) => showModalBottomSheet(
          enableDrag: true,
          context: context,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: radiusApp)),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          builder: (BuildContext context) => BottomSheet(
            enableDrag: false,
            onClosing: () {},
            builder: (BuildContext context) => _bottomSheetLanguage(context, languageCode),
          ),
        ),
      ),
      SettingsTile.navigation(
        leading: const Icon(Icons.query_stats),
        title: Text('Period of Analytics'.i18n),
        value: Text(periodStats.humanize),
        onPressed: (context) => showModalBottomSheet(
          enableDrag: true,
          context: context,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: radiusApp)),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          builder: (BuildContext context) => BottomSheet(
            enableDrag: false,
            onClosing: () {},
            builder: (BuildContext context) => _bottomSheetPeriodStats(periodStats, context),
          ),
        ),
      ),
      SettingsTile.switchTile(
        onToggle: (value) => localAuth.swapState(),
        initialValue: localAuth.enable,
        leading: const Icon(Icons.fingerprint),
        activeSwitchColor: themeData.colorScheme.primary,
        title: Text('Auth With Biometric'.i18n),
      ),
      SettingsTile.switchTile(
        onToggle: (value) => theme.swapTheme(),
        initialValue: theme.themeMode == ThemeMode.dark,
        leading: const Icon(Icons.brightness_auto),
        activeSwitchColor: themeData.colorScheme.primary,
        title: Text('Dark Theme'.i18n),
      ),
    ]);
  }

  SettingsSection getIntegration(User user) {
    return SettingsSection(
      title: Text('Integrations'.i18n, style: _titleStyle),
      tiles: [
        SettingsTile.navigation(
          leading: const Icon(Icons.wallet),
          title: const Text('Wise'),
          onPressed: (_) => showBottomSheetWiseIntegration(user),
          trailing: IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => showBottomSheetWiseIntegration(user),
          ),
        )
      ],
    );
  }

  showBottomSheetWiseIntegration(User user) {
    String apiKey = user.integrations[IntegrationType.wise] ?? '';

    return showModalBottomSheet(
      enableDrag: false,
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: radiusApp)),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext context) => BottomSheet(
        enableDrag: false,
        onClosing: () {},
        builder: (BuildContext context) => _wiseBottomSheetBody(apiKey, user, context),
      ),
    );
  }

  _wiseBottomSheetBody(String apiKey, User user, BuildContext context) {
    return SingleChildScrollView(
        child: Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Padding(
        padding: const EdgeInsets.only(top: 30, bottom: 10, left: 20, right: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${'Update'.i18n} ${'Integrations'.i18n}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextFormField(
              initialValue: apiKey,
              decoration: InputStyle.inputDecoration(labelTextStr: 'API Key'),
              validator: (String? value) => value!.isEmpty ? 'Is Required'.i18n : null,
              onChanged: (String newApiKey) => apiKey = newApiKey,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                buttonCancelContext(context),
                ElevatedButton(
                  child: Text('Update'.i18n),
                  onPressed: () {
                    user.integrations.update(IntegrationType.wise, (value) => apiKey, ifAbsent: () => apiKey);
                    UserService().update(user);
                    setState(() => {});
                    Navigator.pop(context);
                  },
                ),
              ],
            )
          ],
        ),
      ),
    ));
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
          title: Text('${'Please write'.i18n} \'$confirmationString\'..'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('To delete permanently your user and all the data related to you.'.i18n),
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
                child: Text('Delete'.i18n),
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
        Text('Danger Zone'.i18n, style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.error)),
        spacing,
        ElevatedButton(
          style: ButtonThemeStyle.getStyle(ThemeTypes.warn, context),
          onPressed: () async {
            if (await _confirm(context, 'Delete'.i18n) == true) await userService.delete(userId);
          },
          child: Text('DELETE USER'.i18n),
        ),
        spacing,
      ],
    );
  }
}

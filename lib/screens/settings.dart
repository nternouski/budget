import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';

import '../i18n/index.dart';
import '../server/auth.dart';
import '../components/profile_settings.dart';
import '../components/current_rates_settings.dart';
import '../common/classes.dart';
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

class DefaultBalanceOption {
  final String title;
  final ShowBalance balance;

  const DefaultBalanceOption({required this.title, required this.balance});
}

class SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // ignore: unnecessary_cast
    final user = Provider.of<User>(context) as User?;

    return Scaffold(
      appBar: AppBar(
        titleTextStyle: theme.textTheme.titleLarge,
        leading: getLadingButton(context),
        title: Text('Settings'.i18n),
      ),
      body: CustomScrollView(physics: const BouncingScrollPhysics(), slivers: [
        SliverToBoxAdapter(
          child: ValueListenableBuilder<PeriodStats>(
            valueListenable: periods.selected,
            builder: (context, periodStats, child) {
              List<AbstractSettingsSection> sections = [];
              if (user != null) {
                sections = [
                  ProfileSettings(user: user),
                  getCommon(context, theme, periodStats),
                  getIntegration(theme, user),
                  CurrentRatesSettings(user: user),
                  DangerZone(userId: user.id),
                ];
              }
              return SettingsList(
                shrinkWrap: true,
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
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 30, top: 30, left: 20, right: 20),
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
                activeColor: theme.colorScheme.primary,
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
    );
  }

  _bottomSheetLanguage(BuildContext context, String languageCode) {
    final theme = Theme.of(context);
    final langNotifier = Provider.of<LanguageNotifier>(context);

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 30, top: 30, left: 20, right: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Choose Language'.i18n, style: theme.textTheme.titleLarge),
            const SizedBox(height: 10),
            ...[
              const LocaleOption(title: 'Español', locale: Locale('es')),
              const LocaleOption(title: 'English', locale: Locale('en')),
            ].map(
              (option) => ListTile(
                title: Text(option.title),
                onTap: () async {
                  final locale = option.locale ?? ui.window.locale;
                  await langNotifier.setLocale(locale);
                  I18n.of(context).locale = locale;
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  _bottomSheetDefaultBalance(BuildContext context, DailyItemBalanceNotifier balance) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 30, top: 30, left: 20, right: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Show Default Currency'.i18n, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            ...[
              const DefaultBalanceOption(title: 'Original', balance: ShowBalance.Original),
              const DefaultBalanceOption(title: 'Default', balance: ShowBalance.Default),
              DefaultBalanceOption(title: 'Both'.i18n, balance: ShowBalance.Both),
            ].map(
              (option) => ListTile(
                title: Text(option.title),
                onTap: () async {
                  await balance.setAsDefaultCurrency(option.balance);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  SettingsSection getCommon(BuildContext context, ThemeData themeData, PeriodStats periodStats) {
    final theme = Provider.of<ThemeProvider>(context);
    final localAuth = Provider.of<LocalAuthNotifier>(context);
    final balance = Provider.of<DailyItemBalanceNotifier>(context);
    final languageCode = I18n.of(context).locale.languageCode;

    final titleStyle = themeData.textTheme.titleMedium;
    final dataStyle = themeData.textTheme.bodyMedium!.copyWith(color: themeData.hintColor);

    return SettingsSection(
        title: Text(
          'Common'.i18n,
          style: themeData.textTheme.titleMedium!.copyWith(color: themeData.colorScheme.primary),
        ),
        tiles: [
          SettingsTile.navigation(
            leading: const Icon(Icons.language),
            title: Text('Language'.i18n, style: titleStyle),
            value: Text(languageCode.toUpperCase(), style: dataStyle),
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
            title: Text('Period of Analytics'.i18n, style: titleStyle),
            value: Text(periodStats.humanize, style: dataStyle),
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
          SettingsTile.navigation(
            leading: const Icon(Icons.attach_money_outlined),
            title: Text('Show Default Currency'.i18n, style: titleStyle),
            value: Text(balance.showDefault.name, style: dataStyle),
            onPressed: (context) => showModalBottomSheet(
              enableDrag: true,
              context: context,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: radiusApp)),
              clipBehavior: Clip.antiAliasWithSaveLayer,
              builder: (BuildContext context) => BottomSheet(
                enableDrag: false,
                onClosing: () {},
                builder: (BuildContext context) => _bottomSheetDefaultBalance(context, balance),
              ),
            ),
          ),
          SettingsTile.switchTile(
            enabled: localAuth.available,
            onToggle: (value) => localAuth.swapState(),
            initialValue: localAuth.enable,
            leading: const Icon(Icons.fingerprint),
            activeSwitchColor: themeData.colorScheme.primary,
            title: Text('Auth With Biometric'.i18n, style: titleStyle),
          ),
          SettingsTile.switchTile(
            onToggle: (value) => theme.swapTheme(),
            initialValue: theme.themeMode == ThemeMode.dark,
            leading: const Icon(Icons.brightness_auto),
            activeSwitchColor: themeData.colorScheme.primary,
            title: Text('Dark Theme'.i18n, style: titleStyle),
          ),
        ]);
  }

  SettingsSection getIntegration(ThemeData themeData, User user) {
    return SettingsSection(
      title: Text(
        'Integrations'.i18n,
        style: themeData.textTheme.titleMedium!.copyWith(color: themeData.colorScheme.primary),
      ),
      tiles: [
        SettingsTile.navigation(
          leading: const Icon(Icons.wallet),
          title: Text('Wise', style: themeData.textTheme.titleMedium),
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
    final theme = Theme.of(context);
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 30, top: 30, left: 20, right: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${'Save'.i18n} ${'Integrations'.i18n}', style: theme.textTheme.titleLarge),
            TextFormField(
              initialValue: apiKey,
              decoration: const InputDecoration(labelText: 'API Key'),
              validator: (String? value) => value!.isEmpty ? 'Is Required'.i18n : null,
              onChanged: (String newApiKey) => apiKey = newApiKey,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                getButtonCancelContext(context),
                FilledButton(
                  child: Text('Save'.i18n),
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
    );
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
              decoration: InputDecoration(labelText: '', hintText: confirmationString),
              onChanged: (input) => buttonEnabled.value = confirmController.text == confirmationString,
            ),
          ]),
          actions: <Widget>[
            getButtonCancelContext(context),
            ValueListenableBuilder(
              valueListenable: buttonEnabled,
              builder: (BuildContext context, bool enabled, _) {
                return FilledButton(
                  style: ButtonThemeStyle.getStyle(ThemeTypes.warn, context),
                  onPressed: enabled ? () => Navigator.pop(context, true) : null,
                  child: Text('Delete'.i18n),
                );
              },
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
        const Divider(thickness: 1),
        spacing,
        Text('Danger Zone'.i18n, style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.error)),
        spacing,
        FilledButton(
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

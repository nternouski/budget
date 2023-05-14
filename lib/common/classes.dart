import 'dart:ui' as ui;
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import '../i18n/index.dart';
import '../common/preference.dart';
import '../common/styles.dart';

abstract class ModelCommonFunctions {
  ModelCommonFunctions.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}

abstract class ModelCommonInterface extends ModelCommonFunctions {
  late String id;

  ModelCommonInterface.fromJson(super.json) : super.fromJson();
}

class ScreenInit {
  static Widget getScreenInit(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
        body: Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Initializing..'.i18n, style: theme.textTheme.titleMedium),
          const SizedBox(height: 30),
          getLoadingProgress(context: context)
        ],
      ),
    ));
  }
}

extension DateUtils on DateTime {
  DateTime copyWith({
    int? year,
    int? month,
    int? day,
    int? hour,
    int? minute,
    int? second,
    int? millisecond,
    int? microsecond,
    bool toZeroHours = false,
    bool toLastMomentDay = false,
  }) {
    if (toZeroHours || toLastMomentDay) {
      hour = 0;
      minute = 0;
      second = 0;
      millisecond = 0;
      microsecond = 0;
    }
    var result = DateTime(
      year ?? this.year,
      month ?? this.month,
      day ?? this.day,
      hour ?? this.hour,
      minute ?? this.minute,
      second ?? this.second,
      millisecond ?? this.millisecond,
      microsecond ?? this.microsecond,
    );
    if (toLastMomentDay) {
      return result.add(const Duration(days: 1)).subtract(const Duration(microseconds: 1));
    } else {
      return result;
    }
  }
}

class LanguageNotifier extends ChangeNotifier {
  Locale _locale = Locale(Intl.shortLocale(ui.window.locale.languageCode));
  UniqueKey i18nUniqueKey = UniqueKey();
  final Preferences _preferences = Preferences();

  LanguageNotifier() {
    _preferences.getString(PreferenceType.languageCode).then((languageCode) {
      if (languageCode != null && languageCode != '') _locale = Locale(languageCode);
      i18nUniqueKey = UniqueKey();
      notifyListeners();
    });
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    final String languageCode = Intl.shortLocale(locale.languageCode);
    await _preferences.setString(PreferenceType.languageCode, languageCode);
    notifyListeners();
  }

  String get localeShort => Intl.shortLocale(_locale.languageCode);
  Locale get locale => _locale;
}

enum ShowBalance { original, defaultValue, both }

class DailyItemBalanceNotifier extends ChangeNotifier {
  ShowBalance _showDefault = ShowBalance.original;
  final Preferences _preferences = Preferences();

  DailyItemBalanceNotifier() {
    _preferences.getString(PreferenceType.dailyItemBalance).then((dailyItemBalance) {
      if (dailyItemBalance == 'original') {
        _showDefault = ShowBalance.original;
      } else if (dailyItemBalance == 'default') {
        _showDefault = ShowBalance.defaultValue;
      } else {
        _showDefault = ShowBalance.both;
      }
      notifyListeners();
    });
  }

  Future<void> setAsDefaultCurrency(ShowBalance balance) async {
    _showDefault = balance;
    await _preferences.setString(PreferenceType.dailyItemBalance, balance.name);
    notifyListeners();
  }

  ShowBalance get showDefault => _showDefault;
}

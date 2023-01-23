import 'package:flutter/material.dart';

import '../common/preference.dart';
import '../i18n/index.dart';

class PeriodStats {
  final int days;
  late String humanize;

  PeriodStats({required this.days}) {
    humanize = days < 30 ? '%d Days'.plural(days) : '%d Months'.plural(days / 30);
  }
}

class Periods {
  final Preferences _preferences = Preferences();

  static final List<PeriodStats> options = [
    PeriodStats(days: 14),
    PeriodStats(days: 30),
    PeriodStats(days: 60),
    PeriodStats(days: 90),
  ];

  static final _defaultOption = Periods.options[1];
  ValueNotifier<PeriodStats> selected = ValueNotifier<PeriodStats>(_defaultOption);

  Periods() {
    _preferences.getInt(PreferenceType.periodStats).then((days) {
      selected.value = options.firstWhere((element) => element.days == days, orElse: () => _defaultOption);
      selected.notifyListeners();
    });
  }

  update(int days) {
    _preferences.setInt(PreferenceType.periodStats, days);
    selected.value = options.firstWhere((element) => element.days == days, orElse: () => _defaultOption);
    selected.notifyListeners();
  }
}

Periods periods = Periods();

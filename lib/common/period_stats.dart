import 'package:budget/common/preference.dart';
import 'package:flutter/cupertino.dart';

class PeriodStats {
  final int days;
  final String humanize;

  const PeriodStats({required this.days, required this.humanize});
}

class Periods {
  final Preferences _preferences = Preferences();

  static final List<PeriodStats> options = [
    const PeriodStats(days: 14, humanize: '14 Days'),
    const PeriodStats(days: 30, humanize: '1 Month'),
    const PeriodStats(days: 60, humanize: '2 Month'),
    const PeriodStats(days: 90, humanize: '3 Month'),
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

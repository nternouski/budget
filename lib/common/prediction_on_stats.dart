import 'package:flutter/material.dart';

import '../common/preference.dart';

class PredictionOnStatsNotifier extends ChangeNotifier {
  bool enable = false;
  final Preferences _preferences = Preferences();

  PredictionOnStatsNotifier() {
    _preferences.getBool(PreferenceType.predictionOnStats).then((init) {
      enable = init ?? enable;
      notifyListeners();
    });
  }

  Future<void> toggleState() async {
    enable = !enable;
    await _preferences.setBool(PreferenceType.predictionOnStats, enable);
    notifyListeners();
  }
}

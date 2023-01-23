import 'package:i18n_extension/i18n_extension.dart';

import './server.dart';
import './components.dart';
import './common.dart';
import './screens.dart';

extension Localization on String {
  static final _t = screens * common * components * server;

  String get i18n {
    _checkKeys();
    return localize(this, _t);
  }

  String plural(value) {
    _checkKeys();
    return localizePlural(value, this, _t);
  }

  String fill(List<Object> params) {
    _checkKeys();
    return localizeFill(this, params);
  }

  void _checkKeys() {
    toString(Set<TranslatedString> missing) => missing.toList().map((e) => '${e.locale} | ${e.text}').join('\n\n');
    if (Translations.missingKeys.isNotEmpty) {
      throw 'Missing Translation Keys: \n${toString(Translations.missingKeys)}\n';
    }
    if (Translations.missingTranslations.isNotEmpty) {
      throw 'Missing Translations: \n${toString(Translations.missingTranslations)}\n';
    }
  }
}

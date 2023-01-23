import 'dart:developer';

import 'package:flutter/gestures.dart';
import 'package:intl/intl.dart';
import 'package:intl/intl_standalone.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

import '../i18n/index.dart';
import '../common/theme.dart';

abstract class ModelCommonInterface {
  late String id;

  ModelCommonInterface.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}

class ScreenInit {
  static Widget getScreenInit(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Initializing..'.i18n, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
          const SizedBox(height: 30),
          Progress.getLoadingProgress(context: context)
        ],
      ),
    ));
  }
}

class AboutDialogClass {
  static show(BuildContext context) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final theme = Theme.of(context);

    return showAboutDialog(
      context: context,
      applicationIcon: Image.asset('assets/logo.png', width: 40, height: 40),
      applicationName: packageInfo.appName,
      applicationVersion: packageInfo.version,
      applicationLegalese: '© 2023 ${packageInfo.appName}',
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 15),
          child: Column(children: [
            Text('${'Is created by'.i18n} Sebastian Ternouski', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 10),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Terms & Conditions'.i18n,
                    style: TextStyle(color: theme.colorScheme.primary, decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        try {
                          launchUrl(Uri.https('nternouski.web.app', '/apps/budget/terms'),
                              mode: LaunchMode.inAppWebView);
                        } catch (e) {
                          debugPrint(e.toString());
                        }
                      },
                  ),
                  const TextSpan(text: '\n'),
                  TextSpan(
                    text: 'Privacy Policy'.i18n,
                    style: TextStyle(color: theme.colorScheme.primary, decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        try {
                          launchUrl(Uri.https('nternouski.web.app', '/apps/budget/privacy-policy'),
                              mode: LaunchMode.inAppWebView);
                        } catch (e) {
                          debugPrint(e.toString());
                        }
                      },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => _redirect(Uri.https('www.freepik.com', '/author/stories')),
              child:
                  Text('Special thanks to "stories" on freepik for the pictures.', style: theme.textTheme.bodyMedium),
            ),
          ]),
        )
      ],
    );
  }

  static _redirect(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.inAppWebView);
    } else {
      throw 'Could not launch ${uri.toString()}';
    }
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
  }) {
    if (toZeroHours) {
      hour = 0;
      minute = 0;
      second = 0;
      millisecond = 0;
      microsecond = 0;
    }
    return DateTime(
      year ?? this.year,
      month ?? this.month,
      day ?? this.day,
      hour ?? this.hour,
      minute ?? this.minute,
      second ?? this.second,
      millisecond ?? this.millisecond,
      microsecond ?? this.microsecond,
    );
  }
}

class LanguageNotifier extends ChangeNotifier {
  Locale _locale;

  LanguageNotifier(this._locale);

  void setLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }

  String get localeShort => Intl.shortLocale(_locale.languageCode);
}

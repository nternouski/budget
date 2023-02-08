// ignore_for_file: use_build_context_synchronously

import 'package:flutter/gestures.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

import '../i18n/index.dart';
import '../common/version_checker.dart';

class AboutDialog {
  static show(BuildContext context) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final theme = Theme.of(context);

    return showAboutDialog(
      context: context,
      applicationIcon: Image.asset('assets/logo.png', width: 40, height: 40),
      applicationName: packageInfo.appName,
      applicationVersion: packageInfo.version,
      applicationLegalese: '© 2023 ${packageInfo.appName} - Sebastian Ternouski.',
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () => AppVersionChecker().openStore(),
                child: const Text('Open Store'),
              ),
              RichText(
                text: TextSpan(
                  children: [
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
                    TextSpan(
                      text: '\n${'Terms & Conditions'.i18n}',
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
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
        TextButton(
          onPressed: () => _redirect(Uri.https('www.freepik.com', '/author/stories')),
          child: Text('Special thanks to "stories" on freepik for the pictures.', style: theme.textTheme.bodyMedium),
        ),
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

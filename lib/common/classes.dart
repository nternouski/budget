import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

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
          const Text('Inicializando..', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
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
      applicationIcon: const FlutterLogo(),
      applicationName: packageInfo.appName,
      applicationVersion: packageInfo.version,
      applicationLegalese: '©2022 ${packageInfo.appName}',
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 15),
          child: Column(children: [
            Text('This app is created by Sebastian Ternouski', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => _redirect(Uri.https('nternouski.web.app', '/apps/budget/terms')),
                  child: const Text('T & C'),
                ),
                TextButton(
                  onPressed: () => _redirect(Uri.https('nternouski.web.app', '/apps/budget/privacy-policy')),
                  child: const Text('Privacy Policy'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => _redirect(Uri.https('www.freepik.com', '/author/stories')),
              child: Text('Special thanks to "stories" on freepik.', style: theme.textTheme.bodyMedium),
            ),
          ]),
        )
      ],
    );
  }

  static _redirect(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch ${uri.toString()}';
    }
  }
}

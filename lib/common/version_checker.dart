// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:in_app_review/in_app_review.dart';

import '../i18n/index.dart';
import '../model/transaction.dart';
import '../model/user.dart';
import '../server/user_service.dart';

enum AndroidStore { googlePlayStore, apkPure }

class AppVersionChecker {
  /// The current version of the app.
  /// if [currentVersion] is null the [currentVersion] will take the Flutter package version
  final String? currentVersion;

  /// The id of the app (com.exemple.your_app).
  /// if [appId] is null the [appId] will take the Flutter package identifier
  final String? appId;

  /// Select The marketplace of your app
  /// default will be `AndroidStore.GooglePlayStore`
  final AndroidStore androidStore;

  final _inAppReview = InAppReview.instance;

  AppVersionChecker({
    this.currentVersion,
    this.appId,
    this.androidStore = AndroidStore.googlePlayStore,
  });

  Future<AppCheckerResult> getStatus() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final _currentVersion = currentVersion ?? packageInfo.version;
    final _packageName = appId ?? packageInfo.packageName;
    if (Platform.isAndroid) {
      switch (androidStore) {
        case AndroidStore.apkPure:
          return await _checkApkPureStore(_currentVersion, _packageName);
        default:
          return await _checkPlayStore(_currentVersion, _packageName);
      }
    } else if (Platform.isIOS) {
      return await _checkAppleStore(_currentVersion, _packageName);
    } else {
      return AppCheckerResult(_currentVersion, null, '',
          'The target platform "%s" is not yet supported by this package.'.fill([Platform.operatingSystem]));
    }
  }

  Future<AppCheckerResult> _checkAppleStore(String currentVersion, String packageName) async {
    String? errorMsg;
    String? newVersion;
    String? url;
    var uri = Uri.https('itunes.apple.com', '/lookup', {'bundleId': packageName});
    try {
      final response = await http.get(uri);
      if (response.statusCode != 200) {
        errorMsg = "Can't find an app in the Apple Store with the id: $packageName";
      } else {
        final jsonObj = jsonDecode(response.body);
        final List results = jsonObj['results'];
        if (results.isEmpty) {
          errorMsg = "Can't find an app in the Apple Store with the id: $packageName";
        } else {
          newVersion = results[0]['version'];
          url = results[0]['trackViewUrl'];
        }
      }
    } catch (e) {
      errorMsg = '$e';
    }
    return AppCheckerResult(currentVersion, newVersion, url, errorMsg);
  }

  Future<AppCheckerResult> _checkPlayStore(String currentVersion, String packageName) async {
    String? errorMsg;
    String? newVersion;
    String? url;
    final uri = Uri.https('play.google.com', '/store/apps/details', {'id': packageName});
    try {
      final response = await http.get(uri);
      if (response.statusCode != 200) {
        errorMsg = "Can't find an app in the Google Play Store with the id: $packageName";
      } else {
        newVersion = RegExp(r',\[\[\["([0-9,\.]*)"]],').firstMatch(response.body)!.group(1);
        url = uri.toString();
      }
    } catch (e) {
      errorMsg = '$e';
      debugPrint('$uri');
    }
    return AppCheckerResult(currentVersion, newVersion, url, errorMsg);
  }

  Future<AppCheckerResult> _checkApkPureStore(String currentVersion, String packageName) async {
    String? errorMsg;
    String? newVersion;
    String? url;
    Uri uri = Uri.https('apkpure.com', '$packageName/$packageName');
    try {
      final response = await http.get(uri);
      if (response.statusCode != 200) {
        errorMsg = "Can't find an app in the ApkPure Store with the id: $packageName";
      } else {
        newVersion = RegExp(r'<div class="details-sdk"><span itemprop="version">(.*?)<\/span>for Android<\/div>')
            .firstMatch(response.body)!
            .group(1)!
            .trim();
        url = uri.toString();
      }
    } catch (e) {
      errorMsg = '$e';
    }
    return AppCheckerResult(currentVersion, newVersion, url, errorMsg);
  }

  Future<void> askReview(User user, List<Transaction> transactions) async {
    if (!user.reviewRequested && transactions.length >= 10) {
      if (await _inAppReview.isAvailable()) {
        await _inAppReview.requestReview();
        user.reviewRequested = true;
        await UserService().update(user);
      }
    }
  }

  Future<void> openStore() {
    return _inAppReview.openStoreListing(appStoreId: 'com.nternouski.budget');
  }
}

class AppCheckerResult {
  /// return current app version
  final String currentVersion;

  /// return the new app version
  final String? newVersion;

  /// return the app url
  final String? appURL;

  /// return error message if found else it will return `null`
  final String? errorMessage;

  AppCheckerResult(this.currentVersion, this.newVersion, this.appURL, this.errorMessage);

  /// return `true` if update is available
  bool get canUpdate => _shouldUpdate(currentVersion, (newVersion ?? currentVersion));

  bool _shouldUpdate(String versionA, String versionB) {
    final versionNumbersA = versionA.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final versionNumbersB = versionB.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    final int versionASize = versionNumbersA.length;
    final int versionBSize = versionNumbersB.length;

    for (int i = 0; i < math.max(versionASize, versionBSize); i++) {
      final subA = i < versionASize ? versionNumbersA[i] : 0;
      final subB = i < versionBSize ? versionNumbersB[i] : 0;
      if (subA > subB) return false;
      if (subA < subB) return true;
    }
    return false;
  }

  @override
  String toString() {
    return 'Current Version: $currentVersion\nNew Version: $newVersion\nApp URL: $appURL\ncan update: $canUpdate\nerror: $errorMessage';
  }
}

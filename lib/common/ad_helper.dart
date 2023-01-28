import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AdStateNotifier extends ChangeNotifier {
  // ignore: constant_identifier_names
  static const int MAXIMUM_NUMBER_OF_AD_REQUEST = 5;
  Future<InitializationStatus> initialization;

  AdStateNotifier({required this.initialization}) {
    initialization.then((value) => notifyListeners());
  }

  String get bannerAdUnitId {
    String? key;

    if (Platform.isAndroid) {
      key = dotenv.env['BANNER_AD_UNIT_ID_ANDROID'];
    } else if (Platform.isIOS) {
      key = dotenv.env['BANNER_AD_UNIT_ID_IOS'];
    } else {
      throw UnsupportedError('bannerAdUnitId - Unsupported platform');
    }
    if (key != null) return key;
    throw ErrorWidget('bannerAdUnitId - Key not found!');
  }

  String get interstitialAdUnitId {
    String? key;

    if (Platform.isAndroid) {
      key = dotenv.env['INTERSTITIAL_AD_UNIT_ID_ANDROID'];
    } else if (Platform.isIOS) {
      key = dotenv.env['INTERSTITIAL_AD_UNIT_ID_IOS'];
    } else {
      throw UnsupportedError('interstitialAdUnitId - Unsupported platform');
    }
    if (key != null) return key;
    throw ErrorWidget('interstitialAdUnitId - Key not found!');
  }

  String get rewardedAdUnitId {
    String? key;

    if (Platform.isAndroid) {
      key = dotenv.env['REWARDED_AD_UNIT_ID_ANDROID'];
    } else if (Platform.isIOS) {
      key = dotenv.env['REWARDED_AD_UNIT_ID_IOS'];
    } else {
      throw UnsupportedError('rewardedAdUnitId - Unsupported platform');
    }
    if (key != null) return key;
    throw ErrorWidget('rewardedAdUnitId - Key not found!');
  }

  BannerAdListener Function({Function()? onFailed}) get bannerAdListener => _getBanner;

  BannerAdListener _getBanner({Function()? onFailed}) {
    return BannerAdListener(
      // Called when un ad is successfully received.
      onAdLoaded: (Ad ad) => debugPrint('Ad loaded.'),
      // Called when an ad request failed.
      onAdFailedToLoad: (Ad ad, LoadAdError error) {
        ad.dispose();
        if (onFailed != null) onFailed();
        debugPrint('Ad failed to Load: ${error.toString()}');
      },
      // Called when an ad opens an overlay that covers the screen.
      onAdOpened: (Ad ad) => debugPrint('Ad opened.'),
      // Called when an ad removes an overlay that covers the screen.
      onAdClosed: (Ad ad) => debugPrint('Ad closed.'),
      // Called when an ad is in the process of leaving the application.
      onAdWillDismissScreen: (Ad ad) => debugPrint('Left application.'),
    );
  }
}

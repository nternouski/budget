import 'dart:io';

import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';

class DeviceInfoNotifier extends ChangeNotifier {
  bool _isPhysicalDevice = false;

  DeviceInfoNotifier() {
    Future.wait([isPhysicalDeviceFn()]).then((promise) {
      _isPhysicalDevice = promise[0];
    });
  }

  bool get isPhysicalDevice => _isPhysicalDevice;

  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  Future<bool> isPhysicalDeviceFn() async {
    if (Platform.isAndroid) {
      return (await _deviceInfo.androidInfo).isPhysicalDevice;
    } else if (Platform.isIOS) {
      return (await _deviceInfo.iosInfo).isPhysicalDevice;
    } else {
      throw UnsupportedError('isPhysicalDevice - Unsupported platform');
    }
  }
}

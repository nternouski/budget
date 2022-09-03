import 'dart:developer';
import 'dart:math';
import 'package:flutter/material.dart';

import './icon_helper.dart';

class Convert {
  static double currencyToDouble(String? currency, dynamic context) {
    if (currency == null) inspect(context);
    currency ??= '\$ -1';
    return double.parse(currency.replaceAll(RegExp(r'[\$,]'), ''));
  }

  static DateTime parseDate(String date) {
    try {
      return DateTime.parse(date);
    } catch (e) {
      return DateTime.now();
    }
  }

  static IconData toIcon(String icon) {
    return IconsHelper.iconMap[icon] ?? Icons.question_mark;
  }

  static Color colorFromHex(String hex) {
    return Color(int.parse(hex, radix: 16));
  }

  static String colorToHexString(Color color) {
    return color.value.toRadixString(16);
  }

  static String roundMoney(double money) {
    if (money > 1000) return '${(money ~/ 1000)}k'.toString();
    return money.toInt().toString();
  }

  static double roundDouble(double value, int decimal) {
    return double.parse(value.toStringAsFixed(decimal));
  }

  static String capitalize(String text) {
    return '${text[0].toUpperCase()}${text.substring(1).toLowerCase()}';
  }

  static Color increaseColorSaturation(Color color, double increment) {
    var hslColor = HSLColor.fromColor(color);
    return hslColor.withSaturation(min(max(hslColor.saturation + increment, 0.0), 1.0)).toColor();
  }

  static Color increaseColorLightness(Color color, double increment) {
    var hslColor = HSLColor.fromColor(color);
    return hslColor.withLightness(min(max(hslColor.lightness + increment, 0.0), 1.0)).toColor();
  }

  static Color increaseColorHue(Color color, double increment) {
    var hslColor = HSLColor.fromColor(color);
    return hslColor.withHue(min(max(hslColor.lightness + increment, 0.0), 360.0)).toColor();
  }
}

import 'dart:developer';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import './icon_helper.dart';

class Convert {
  static double currencyToDouble(dynamic currency, dynamic contextOfConversion) {
    if (currency == null) {
      debugPrint('<< ERROR IN currencyToDouble >>');
      inspect(contextOfConversion);
      currency = '\$ -1';
    }
    return double.parse('$currency'.replaceAll(RegExp(r'[\$,]'), ''));
  }

  static DateTime parseDate(dynamic date, dynamic contextOfConversion) {
    try {
      if (date == null) {
        debugPrint('<< ERROR IN parseDate >>');
        inspect(contextOfConversion);
        date = DateTime.now();
      }
      if (date is Timestamp) return date.toDate();
      return date is String ? DateTime.parse(date) : date;
    } catch (e) {
      inspect(e);
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

import 'package:flutter/material.dart';
import './icon_helper.dart';

class Convert {
  static double currencyToDouble(String currency) {
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
}

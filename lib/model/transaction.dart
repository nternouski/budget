import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum TransactionType {
  income,
  expense,
  transfer,
}

class Transaction {
  String id;
  String name;
  int amount;
  String categoryId;
  DateTime date;
  String walletId;
  TransactionType type;
  String description;

  Transaction(
      {required this.name,
      required this.amount,
      required this.categoryId,
      required this.date,
      required this.walletId,
      required this.type,
      required this.description,
      required this.id});

  setTime({int hour = 0, int minute = 0}) {
    date = DateTime(date.year, date.month, date.day, hour, minute);
  }

  getTime() {
    return TimeOfDay(hour: date.hour, minute: date.minute);
  }

  String getDateFormat() {
    var now = DateTime.now();
    if (date.isBefore(now.subtract(const Duration(days: 360)))) {
      return DateFormat(DateFormat.YEAR_NUM_MONTH_DAY).format(date);
    } else if (date.isBefore(now.subtract(const Duration(days: 30)))) {
      return DateFormat(DateFormat.MONTH_WEEKDAY_DAY).format(date);
    } else {
      return DateFormat(DateFormat.HOUR24_MINUTE).format(date);
    }
  }
}

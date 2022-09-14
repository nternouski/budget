import 'package:budget/model/currency.dart';
import 'package:flutter/material.dart';
import '../common/classes.dart';
import '../common/convert.dart';

class Wallet implements ModelCommonInterface {
  // ignore: non_constant_identifier_names
  static int MAX_LENGTH_NAME = 16;

  @override
  String id;
  DateTime createdAt;
  String name;
  late Color color;
  late IconData icon;
  String iconName;
  double initialAmount;
  double balance;
  double balanceFixed;
  String currencyId;
  Currency? currency;

  Wallet({
    required this.id,
    required this.createdAt,
    required this.name,
    required String color,
    required this.iconName,
    required this.initialAmount,
    required this.balance,
    required this.balanceFixed,
    required this.currencyId,
  }) {
    icon = Convert.toIcon(iconName);
    this.color = Convert.colorFromHex(color);
  }

  factory Wallet.fromJson(Map<String, dynamic> json) {
    double initialAmount = Convert.currencyToDouble(json['initialAmount'], json);
    Wallet wallet = Wallet(
      id: json['id'],
      createdAt: Convert.parseDate(json['createdAt'], json),
      name: json['name'],
      color: json['color'],
      iconName: json['icon'],
      initialAmount: initialAmount,
      balance: Convert.currencyToDouble(json['balance'], json),
      balanceFixed: Convert.currencyToDouble(json['balanceFixed'], json),
      currencyId: json['currencyId'],
    );
    return wallet;
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{
      'id': id,
      'createdAt': createdAt,
      'name': name,
      'color': Convert.colorToHexString(color),
      'icon': iconName,
      'balance': balance,
      'balanceFixed': balanceFixed,
      'initialAmount': initialAmount,
      'currencyId': currencyId,
    };
    return data;
  }
}

final defaultWallet = Wallet(
  id: '',
  createdAt: DateTime.now(),
  name: '',
  color: 'ff448aff',
  iconName: 'question_mark',
  initialAmount: 0,
  currencyId: '',
  balance: 0,
  balanceFixed: 0,
);

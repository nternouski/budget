import 'package:flutter/material.dart';

import '../model/currency.dart';
import '../model/transaction.dart';
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

  /// Update the balance depending of the transaction and if and update from old balance
  void updateBalance(Transaction transaction, {bool fromOld = false, double? balanceConverted}) {
    if (transaction.type == TransactionType.transfer) {
      if (id == transaction.walletFromId) {
        balance += -(transaction.balance + transaction.fee) * (fromOld ? -1 : 1);
        balanceFixed += -(transaction.balanceFixed + transaction.fee) * (fromOld ? -1 : 1);
      } else if (balanceConverted != null) {
        balance += balanceConverted * (fromOld ? -1 : 1);
        balanceFixed += transaction.balanceFixed * (fromOld ? -1 : 1);
      }
    } else {
      balance += fromOld ? -transaction.balance : transaction.balance;
      balanceFixed += fromOld ? -transaction.balanceFixed : transaction.balanceFixed;
    }
  }

  Wallet copy() {
    return Wallet(
      id: id,
      createdAt: createdAt,
      name: name,
      color: Convert.colorToHexString(color),
      iconName: iconName,
      initialAmount: initialAmount,
      balance: balance,
      balanceFixed: balanceFixed,
      currencyId: currencyId,
    );
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

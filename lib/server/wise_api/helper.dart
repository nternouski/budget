// ---------------------------
//            Money
// ---------------------------

import 'package:budget/common/convert.dart';
import 'package:budget/model/transaction.dart';
import 'package:budget/model/wallet.dart';

class Money {
  final double value;
  final String currency;

  Money({required this.value, required this.currency});

  factory Money.fromJson(Map<String, dynamic> json) {
    return Money(value: json['value'], currency: json['currency']);
  }
}

// ---------------------------
//         WiseProfileBalance
// ---------------------------

class WiseProfileBalance {
  final List<WiseBalance> balances;
  final WiseProfile profile;

  WiseProfileBalance({required this.profile, required this.balances});
}

// ---------------------------
//         WiseProfile
// ---------------------------

class WiseProfile {
  final int id;
  final String type; //  "PERSONAL" | "BUSINESS"
  final int userId;
  final String currentState; // VISIBLE
  final String fullName;

  WiseProfile({
    required this.id,
    required this.type,
    required this.userId,
    required this.currentState,
    required this.fullName,
  });

  factory WiseProfile.fromJson(Map<String, dynamic> json) {
    return WiseProfile(
      id: json['id'],
      type: json['type'],
      userId: json['userId'],
      currentState: json['currentState'],
      fullName: json['fullName'],
    );
  }
}

// ---------------------------
//         WiseBalance
// ---------------------------

class WiseBalance {
  int id;
  String type; // "STANDARD",
  String currency; // "AUD",

  Money amount;
  Money reservedAmount;
  Money cashAmount;
  Money totalWorth;

  String investmentState;
  bool visible;

  int profileId;

  WiseBalance({
    required this.id,
    required this.type,
    required this.currency,
    required this.amount,
    required this.reservedAmount,
    required this.cashAmount,
    required this.totalWorth,
    required this.investmentState,
    required this.visible,
    required this.profileId,
  });

  factory WiseBalance.fromJson(Map<String, dynamic> json, int profileId) {
    return WiseBalance(
      id: json['id'],
      type: json['type'],
      currency: json['currency'],
      amount: Money.fromJson(json['amount']),
      reservedAmount: Money.fromJson(json['reservedAmount']),
      cashAmount: Money.fromJson(json['cashAmount']),
      totalWorth: Money.fromJson(json['totalWorth']),
      investmentState: json['investmentState'],
      visible: json['visible'],
      profileId: profileId,
    );
  }
}

// ---------------------------
//         WiseStatementTransactions
// ---------------------------

class WiseStatementTransactions extends Transaction {
  final String typeWise; //  "DEBIT"
  final Money amountWise; // VISIBLE
  final Money totalFeesWise;

  WiseStatementTransactions({
    required super.id,
    required super.name,
    required super.amount,
    required super.fee,
    required super.balance,
    required super.balanceFixed,
    required super.date,
    required super.walletFromId,
    required super.walletToId,
    required super.type,
    required super.description,
    required super.labels,
    required super.categoryId,
    required super.externalId,
    super.category,
    required this.typeWise,
    required this.amountWise,
    required this.totalFeesWise,
  });

  factory WiseStatementTransactions.fromJson(Map<String, dynamic> json, String walletId) {
    var amount = Money.fromJson(json['amount']);
    var totalFees = Money.fromJson(json['totalFees']);
    var balance = amount.value > 0 ? amount.value - totalFees.value : amount.value + totalFees.value;
    return WiseStatementTransactions(
      id: '',
      name: json['details']['description'],
      amount: balance.abs(),
      fee: 0,
      balance: balance,
      balanceFixed: balance,
      date: Convert.parseDate(json['date'], json),
      type: amount.value > 0 ? TransactionType.income : TransactionType.expense,
      description: '${json['details']['type']} - ${json['type']} | ${json['attachment']?['note']}',
      labels: [],
      categoryId: '',
      category: null,
      walletFromId: walletId,
      walletToId: '',
      typeWise: json['type'],
      amountWise: amount,
      totalFeesWise: totalFees,
      externalId: json['referenceNumber'],
    );
  }
}

// ---------------------------
//         WiseTransactions
// ---------------------------

class WiseTransactions extends Transaction {
  final String typeWise; //  "DEBIT"
  final Money amountWise; // VISIBLE
  final Money totalFeesWise;

  WiseTransactions({
    required super.id,
    required super.name,
    required super.amount,
    required super.fee,
    required super.balance,
    required super.balanceFixed,
    required super.date,
    required super.walletFromId,
    required super.walletToId,
    required super.type,
    required super.description,
    required super.labels,
    required super.categoryId,
    required super.externalId,
    super.category,
    required this.typeWise,
    required this.amountWise,
    required this.totalFeesWise,
  });

  factory WiseTransactions.fromJson(Map<String, dynamic> json, Wallet wallet) {
    var amount = Money(currency: json['sourceCurrency'], value: json['sourceValue']);
    return WiseTransactions(
      id: '',
      name: json['details']['reference'] ?? '',
      amount: amount.value.abs(),
      fee: 0,
      balance: amount.value,
      balanceFixed: amount.value,
      date: Convert.parseDate(json['created'], json),
      type: amount.value > 0 ? TransactionType.income : TransactionType.expense,
      description: 'customerTransactionId = ${json['customerTransactionId']} - ${json['business']}',
      labels: [],
      categoryId: '',
      category: null,
      walletFromId: wallet.id,
      walletToId: '',
      typeWise: '',
      amountWise: amount,
      totalFeesWise: Money(currency: json['sourceCurrency'], value: 0),
      externalId: json['id'].toString(),
    );
  }
}

// ---------------------------
//         WiseRate
// ---------------------------
class WiseRate {
  final String source;
  final String target;
  final double rate;
  final DateTime time;
  WiseRate({required this.source, required this.target, required this.rate, required this.time});

  factory WiseRate.fromJson(Map<String, dynamic> json) {
    return WiseRate(
      source: json['source'],
      target: json['target'],
      rate: Convert.currencyToDouble(json['rate'], json),
      time: Convert.parseDate(json['time'], json),
    );
  }
}

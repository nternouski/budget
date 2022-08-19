// ---------------------------
//            Money
// ---------------------------

import 'package:budget/common/convert.dart';
import 'package:budget/model/transaction.dart';

class Money {
  final double value;
  final String currency;

  Money({required this.value, required this.currency});

  factory Money.fromJson(Map<String, dynamic> json) {
    return Money(
      value: json['value'],
      currency: json['currency'],
    );
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
    required super.balance,
    required super.date,
    required super.walletId,
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

  factory WiseTransactions.fromJson(Map<String, dynamic> json, String walletId) {
    var amountWise = Money.fromJson(json['amount']);
    var totalFeesWise = Money.fromJson(json['totalFees']);
    var balance = amountWise.value + totalFeesWise.value; // // ------<<<<
    return WiseTransactions(
      id: '',
      name: 'Example', // json['name'],                     // ------<<<<
      amount: balance.abs(),
      balance: balance,
      date: Convert.parseDate(json['date']),
      type: TransactionType.expense, //                     // ------<<<<
      description: json['details']['description'],
      labels: [],
      categoryId: '',
      category: null,
      walletId: walletId,
      typeWise: json['type'],
      amountWise: amountWise,
      totalFeesWise: totalFeesWise,
      externalId: json['referenceNumber'],
    );
  }
}




// {
//   "accountHolder": {
//     "type": "PERSONAL",
//     "address": {
//       "addressFirstLine": "56 Shoreditch High Street",
//       "city": "London",
//       "postCode": "E16JJ",
//       "stateCode": null,
//       "countryName": "United Kingdom"
//     },
//     "firstName": "Sebastian",
//     "lastName": "Ternouski Test"
//   },
//   "issuer": {
//     "name": "Wise Ltd.",
//     "firstLine": "56 Shoreditch High Street",
//     "city": "London",
//     "postCode": "E1 6JJ",
//     "stateCode": null,
//     "countryCode": "gbr",
//     "country": "United Kingdom"
//   },
//   "bankDetails": [],
//   "transactions": [
//     {
//       "type": "DEBIT",
//       "date": "2022-07-26T23:37:25.42011Z",
//       "amount": {
//         "value": -1000.00,
//         "currency": "AUD",
//         "zero": false
//       },
//       "totalFees": {
//         "value": 14.20,
//         "currency": "AUD",
//         "zero": false
//       },
//       "details": {
//         "type": "CONVERSION",
//         "description": "Converted 1000.00 AUD to 89511.13 ARS",
//         "sourceAmount": {
//           "value": 1000.00,
//           "currency": "AUD",
//           "zero": false
//         },
//         "targetAmount": {
//           "value": 89511.13,
//           "currency": "ARS",
//           "zero": false
//         },
//         "rate": 90.80050000
//       },
//       "exchangeDetails": {
//         "toAmount": {
//           "value": 89511.13,
//           "currency": "ARS",
//           "zero": false
//         },
//         "fromAmount": {
//           "value": 1000.00,
//           "currency": "AUD",
//           "zero": false
//         },
//         "rate": 90.80050
//       },
//       "runningBalance": {
//         "value": 3998885.00,
//         "currency": "AUD",
//         "zero": false
//       },
//       "referenceNumber": "BALANCE-2867099",
//       "attachment": null,
//       "activityAssetAttributions": []
//     },
//     {
//       "type": "DEBIT",
//       "date": "2022-07-24T20:52:14.61478Z",
//       "amount": {
//         "value": -115.00,
//         "currency": "AUD",
//         "zero": false
//       },
//       "totalFees": {
//         "value": 0.00,
//         "currency": "AUD",
//         "zero": true
//       },
//       "details": {
//         "type": "CONVERSION",
//         "description": "Added 115.00 AUD to Jar X",
//         "sourceAmount": {
//           "value": 115.00,
//           "currency": "AUD",
//           "zero": false
//         },
//         "targetAmount": {
//           "value": 115.00,
//           "currency": "AUD",
//           "zero": false
//         },
//         "rate": 1.00000000
//       },
//       "exchangeDetails": null,
//       "runningBalance": {
//         "value": 3999885.00,
//         "currency": "AUD",
//         "zero": false
//       },
//       "referenceNumber": "BALANCE-2862699",
//       "attachment": null,
//       "activityAssetAttributions": []
//     }
//   ],
//   "endOfStatementBalance": {
//     "value": 3998885.00,
//     "currency": "AUD",
//     "zero": false
//   },
//   "endOfStatementUnrealisedGainLoss": null,
//   "balanceAssetConfiguration": null,
//   "query": {
//     "intervalStart": "2022-07-01T00:00:00Z",
//     "intervalEnd": "2022-08-10T23:59:59.999Z",
//     "type": "COMPACT",
//     "currency": "AUD",
//     "profileId": 16550506,
//     "timezone": "Z"
//   },
//   "request": {
//     "id": "0a78ac01-08e5-4a29-cc63-f2ef7dc6be8b",
//     "creationTime": "2022-08-14T21:03:14.498046111Z",
//     "profileId": 16550506,
//     "currency": "AUD",
//     "balanceId": 116680,
//     "balanceName": null,
//     "intervalStart": "2022-07-01T00:00:00Z",
//     "intervalEnd": "2022-08-10T23:59:59.999Z"
//   }
// }
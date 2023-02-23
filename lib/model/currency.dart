import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../common/convert.dart';
import '../common/classes.dart';
import '../common/error_handler.dart';

extension CurrencyPrettier on double {
  static TextStyle getFont(TextStyle style) {
    return style.copyWith(fontFamily: 'Poppins');
  }

  /// Same of prettier but with format Text
  Text prettierToText({
    bool withSymbol = false,
    bool withoutDecimal = false,
    bool simplify = false,
    String prefix = '',
    String suffix = '',
    TextStyle? style,
  }) {
    return Text(
      '$prefix${prettier(withSymbol: withSymbol, simplify: simplify, withoutDecimal: withoutDecimal)}$suffix',
      style: getFont(style ?? const TextStyle()),
    );
  }

  /// The function remove zeros on decimal and round to two decimals.
  /// Examples:
  ///   4.777 => 4.77
  ///   52.0  => 5
  /// Or simplify from 12000 to 12k
  String prettier({bool withSymbol = false, bool simplify = false, bool withoutDecimal = false}) {
    String amount;
    if (simplify) {
      amount = this > 1000 ? '${(_removeZeros(this / 1000, 1))}k' : toInt().toString();
    } else {
      amount = _removeZeros(withoutDecimal ? roundToDouble() : this, 2);
    }
    return '${isNegative ? '- ' : ''}${withSymbol ? '\$' : ''}$amount';
  }

  String _removeZeros(double num, int fixed) {
    return num.abs().toStringAsFixed(fixed).replaceFirst(RegExp(r'\.?0*$'), '');
  }
}

extension CurrencyRateList on List<CurrencyRate> {
  /// Find currency rate, if the currency its the same return class of rate 1.
  CurrencyRate findCurrencyRate(Currency cr1, Currency cr2, {String? errorMessage}) {
    if (cr1.id == cr2.id) {
      return CurrencyRate(
        id: '',
        createdAt: DateTime.now(),
        rate: 1,
        currencyFrom: cr1,
        currencyTo: cr2,
      );
    }
    // ignore: unnecessary_this
    CurrencyRate? cr = this.firstWhereOrNull((r) {
      String from = r.currencyFrom.id;
      String to = r.currencyTo.id;
      return ((from == cr1.id && to == cr2.id) || (to == cr1.id && from == cr2.id));
    });

    if (cr == null) {
      String message =
          'No currency rate of ${cr1.symbol}-${cr2.symbol} or ${cr2.symbol}-${cr1.symbol}, please add it before.';
      HandlerError().setError(errorMessage ?? message);
      throw message;
    }

    return cr;
  }

  notExist(Currency cr1, Currency cr2) {
    // ignore: unnecessary_this
    return this.where((cr) => cr.currencyFrom.id == cr1.id && cr.currencyTo.id == cr2.id).isEmpty;
  }
}

class Currency implements ModelCommonInterface {
  @override
  String id;
  late DateTime createdAt;
  String name;
  String symbol;

  Currency({required this.id, required this.name, required this.symbol, DateTime? createdAt}) {
    this.createdAt = createdAt ?? DateTime.now();
  }

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      id: json['id'],
      createdAt: Convert.parseDate(json['createdAt'], json),
      name: json['name'],
      symbol: json['symbol'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{
      'id': id,
      'createdAt': createdAt,
      'name': name,
      'symbol': symbol,
    };
    return data;
  }
}

///////////////////////////////////////////////
///////////////////////////////////////////////
/////////       CurrencyRates        //////////
///////////////////////////////////////////////
///////////////////////////////////////////////

class CurrencyRate implements ModelCommonInterface {
  @override
  String id;
  DateTime createdAt;

  double rate;
  Currency currencyFrom;
  Currency currencyTo;

  CurrencyRate({
    required this.id,
    required this.createdAt,
    required this.rate,
    required this.currencyFrom,
    required this.currencyTo,
  });

  factory CurrencyRate.fromJson(Map<String, dynamic> json, List<Currency> currencies) {
    Currency? currencyFrom = currencies.firstWhereOrNull((c) => c.id == json['currencyIdFrom']);
    Currency? currencyTo = currencies.firstWhereOrNull((c) => c.id == json['currencyIdTo']);

    if (currencyFrom == null || currencyTo == null) {
      throw Exception('currencyTo or/and currencyFrom not exist on ${json['id']}');
    }
    return CurrencyRate(
      id: json['id'],
      createdAt: Convert.parseDate(json['createdAt'], json),
      rate: double.parse(json['rate'].toString()),
      currencyFrom: currencyFrom,
      currencyTo: currencyTo,
    );
  }

  factory CurrencyRate.init() {
    return CurrencyRate(
      id: '',
      createdAt: DateTime.now(),
      rate: 0,
      currencyFrom: Currency(id: '', name: '', symbol: ''),
      currencyTo: Currency(id: '', name: '', symbol: ''),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{
      'id': id,
      'createdAt': createdAt,
      'rate': rate,
      'currencyIdFrom': currencyFrom.id,
      'currencyIdTo': currencyTo.id,
    };
    return data;
  }

  double convert(double amount, String from, String to) {
    if (from == to) {
      return amount;
    } else {
      return double.parse((currencyFrom.id == from ? amount / rate : amount * rate).toStringAsFixed(2));
    }
  }
}

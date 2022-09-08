import 'package:collection/collection.dart';
import '../common/convert.dart';
import '../common/classes.dart';

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
      createdAt: Convert.parseDate(json['createdAt']),
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
      createdAt: Convert.parseDate(json['createdAt']),
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
}

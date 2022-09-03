import '../common/convert.dart';
import '../common/classes.dart';

class Currency implements ModelCommonInterface {
  @override
  String id;
  String name;
  String symbol;

  Currency({required this.id, required this.name, required this.symbol});

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      id: json['id'],
      name: json['name'],
      symbol: json['symbol'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{
      'id': id,
      'name': name,
      'symbol': symbol,
    };
    return data;
  }
}

class CurrencyQueries implements GraphQlQuery {
  @override
  String getAll = '''
    query getCurrencies {
      currencies(where: {}) {
        id
        name
        symbol
      }
    }''';

  @override
  String create = r'';

  @override
  String update = r'';

  @override
  String delete = r'';
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

  factory CurrencyRate.fromJson(Map<String, dynamic> json) {
    return CurrencyRate(
      id: json['id'],
      createdAt: Convert.parseDate(json['createdAt']),
      rate: double.parse(json['rate'].toString()),
      currencyFrom: Currency.fromJson(json['currency_from']),
      currencyTo: Currency.fromJson(json['currency_to']),
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
      'rate': rate,
      'currencyIdFrom': currencyFrom.id,
      'currencyIdTo': currencyTo.id,
    };
    return data;
  }
}

class CurrencyRateQueries implements GraphQlQuery {
  @override
  String getAll = '''
    query getCurrencyRates {
      currency_rates(where: {}) {
        id
        createdAt
        rate
        currency_from {
          id
          name
          symbol
        }
        currency_to {
          id
          name
          symbol
        }
      }
    }''';

  @override
  String create = r'''
    mutation addCurrencyRates($rate: Float!, $currencyIdFrom: uuid!, $currencyIdTo: uuid!) {
      action: insert_currency_rates(objects: [{ rate: $rate, currencyIdFrom: $currencyIdFrom, currencyIdTo: $currencyIdTo }]) {
        returning {
          id
          createdAt
          rate
          currency_from {
            id
            name
            symbol
          }
          currency_to {
            id
            name
            symbol
          }
        }
      }
    }''';

  @override
  String update = r'''
    mutation updateCurrencyRates($id: uuid!, $rate: Float!, $currencyIdFrom: uuid!, $currencyIdTo: uuid!) {
      action: update_currency_rates(where: {id: {_eq: $id}}, _set: { rate: $rate, currencyIdFrom: $currencyIdFrom, currencyIdTo: $currencyIdTo }) {
        returning {
          id
          createdAt
          rate
          currency_from {
            id
            name
            symbol
          }
          currency_to {
            id
            name
            symbol
          }
        }
      }
    }''';

  @override
  String delete = r'';
}

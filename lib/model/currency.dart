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

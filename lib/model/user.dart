import '../model/currency.dart';
import '../common/classes.dart';
import '../common/convert.dart';

enum IntegrationType { wise }

// extension ParseToString on IntegrationType {
//   String toShortString() {
//     return toString().split('.').last;
//   }
// }
class User implements ModelCommonInterface {
  @override
  String id;
  DateTime createdAt;
  String name;
  String email;
  Map<IntegrationType, String> integrations;
  Currency defaultCurrency;
  double initialAmount;

  User({
    required this.id,
    required this.createdAt,
    required this.name,
    required this.email,
    required this.integrations,
    required this.defaultCurrency,
    this.initialAmount = 0.0,
  });

  factory User.fromJson(Map<String, dynamic> json, Currency defaultCurrency) {
    Map<IntegrationType, String> integrations = (Map.from(json['integrations'] ?? {}))
        .map((key, value) => MapEntry(IntegrationType.values.firstWhere((t) => t.name == key), value));
    return User(
      id: json['id'],
      createdAt: Convert.parseDate(json['createdAt'], json),
      name: json['name'],
      email: json['email'],
      integrations: integrations,
      defaultCurrency: defaultCurrency,
      initialAmount: Convert.currencyToDouble(json['initialAmount'] ?? 0, json),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{
      'id': id,
      'createdAt': createdAt,
      'name': name,
      'email': email,
      'defaultCurrencyId': defaultCurrency.id,
      'initialAmount': initialAmount,
      'integrations': integrations.entries.fold<Map<String, String>>({}, (acc, entry) {
        acc.addAll({entry.key.name: entry.value});
        return acc;
      }),
    };
    return data;
  }
}

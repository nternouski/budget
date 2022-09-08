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
  String defaultCurrencyId;
  Currency? defaultCurrency;
  double initialAmount;

  User({
    required this.id,
    required this.createdAt,
    required this.name,
    required this.email,
    required this.integrations,
    required this.defaultCurrencyId,
    this.defaultCurrency,
    this.initialAmount = 0.0,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    Map<IntegrationType, String> integrations = (Map.from(json['integrations'] ?? {}))
        .map((key, value) => MapEntry(IntegrationType.values.firstWhere((t) => t.name == key), value));
    return User(
      id: json['id'],
      createdAt: Convert.parseDate(json['createdAt']),
      name: json['name'],
      email: json['email'],
      integrations: integrations,
      defaultCurrencyId: json['defaultCurrencyId'] ?? '',
      defaultCurrency: json['currency'] != null ? Currency.fromJson(json['currency']) : null,
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
      'defaultCurrencyId': defaultCurrencyId,
      'initialAmount': initialAmount,
      'integrations': integrations.entries.fold<Map<String, String>>({}, (acc, entry) {
        acc.addAll({entry.key.name: entry.value});
        return acc;
      }),
    };
    return data;
  }
}

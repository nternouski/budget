import '../model/currency.dart';
import '../common/classes.dart';
import '../common/convert.dart';

enum IntegrationType { wise }

// extension ParseToString on IntegrationType {
//   String toShortString() {
//     return toString().split('.').last;
//   }
// }

extension UserValidator on String {
  bool isValidEmail() {
    String regex = r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
    return RegExp(regex).hasMatch(this);
  }

  bool isValidPassword() {
    return this.length >= 6;
  }
}

class User implements ModelCommonInterface {
  @override
  String id;
  DateTime createdAt;
  String name;
  String email;
  Map<IntegrationType, String> integrations;
  Currency defaultCurrency;
  double initialAmount;
  bool superUser;
  DateTime? hideAdsUntil;

  User({
    required this.id,
    required this.createdAt,
    required this.name,
    required this.email,
    required this.integrations,
    required this.defaultCurrency,
    this.superUser = false,
    this.initialAmount = 0.0,
    this.hideAdsUntil,
  });

  factory User.fromJson(Map<String, dynamic> json, Currency defaultCurrency) {
    Map<IntegrationType, String> integrations = (Map.from(json['integrations'] ?? {}))
        .map((key, value) => MapEntry(IntegrationType.values.firstWhere((t) => t.name == key), value));

    bool superUser = json['superUserExpiration'] != null &&
        Convert.parseDate(json['superUserExpiration'], json).isAfter(DateTime.now());

    return User(
      id: json['id'],
      createdAt: Convert.parseDate(json['createdAt'], json),
      name: json['name'],
      email: json['email'],
      integrations: integrations,
      defaultCurrency: defaultCurrency,
      superUser: superUser,
      initialAmount: Convert.currencyToDouble(json['initialAmount'] ?? 0, json),
      hideAdsUntil: json['hideAdsUntil'] != null ? Convert.parseDate(json['hideAdsUntil'], json) : null,
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
      'hideAdsUntil': hideAdsUntil,
    };
    return data;
  }

  bool showAds() {
    return hideAdsUntil != null ? hideAdsUntil!.isBefore(DateTime.now()) : true;
  }
}

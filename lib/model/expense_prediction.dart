import '../model/currency.dart';
import '../common/classes.dart';
import '../common/convert.dart';

class ExpensePredictionItem implements ModelCommonFunctions {
  String name;
  double amount;
  int days;
  bool check;
  DateTime lastPurchaseDate;

  ExpensePredictionItem({
    required this.name,
    required this.amount,
    required this.days,
    required this.check,
    required this.lastPurchaseDate,
  });

  factory ExpensePredictionItem.fromJson(Map<String, dynamic> json) {
    return ExpensePredictionItem(
      name: json['name'],
      amount: Convert.currencyToDouble(json['amount'], json),
      days: Convert.currencyToDouble(json['days'], json).toInt(),
      check: json['check'],
      lastPurchaseDate: Convert.parseDate(json['lastPurchaseDate'] ?? DateTime.now(), json),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{
      'name': name,
      'amount': amount,
      'days': days,
      'check': check,
      'lastPurchaseDate': lastPurchaseDate,
    };
    return data;
  }

  ExpensePredictionItem copyWith({
    String? name,
    double? amount,
    bool? check,
    int? days,
    DateTime? lastPurchaseDate,
  }) {
    return ExpensePredictionItem(
      name: name ?? this.name,
      amount: amount ?? this.amount,
      check: check ?? this.check,
      days: days ?? this.days,
      lastPurchaseDate: lastPurchaseDate ?? this.lastPurchaseDate,
    );
  }

  double getPeriodAmount(int period) {
    return (period / days) * amount;
  }
}

class ExpensePredictionGroup implements ModelCommonFunctions {
  String name;
  List<ExpensePredictionItem> items;
  bool check;
  bool collapse;
  ExpensePredictionGroup({
    required this.name,
    required this.items,
    required this.check,
    required this.collapse,
  });

  factory ExpensePredictionGroup.fromJson(Map<String, dynamic> json) {
    return ExpensePredictionGroup(
      name: json['name'],
      items: List.from(json['items'] ?? []).map((item) => ExpensePredictionItem.fromJson(item)).toList(),
      check: json['check'],
      collapse: json['collapse'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{
      'name': name,
      'items': items.map((item) => item.toJson()).toList(),
      'check': check,
      'collapse': collapse,
    };
    return data;
  }
}

class ExpensePredictionGroupTotal extends ExpensePredictionGroup {
  late double total;
  ExpensePredictionGroupTotal({
    required super.name,
    required super.items,
    required super.check,
    required super.collapse,
    required int period,
  }) {
    updateTotal(period);
  }

  factory ExpensePredictionGroupTotal.fromExpensePredictionGroup(ExpensePredictionGroup epg, int period) {
    return ExpensePredictionGroupTotal(
      name: epg.name,
      items: epg.items,
      check: epg.check,
      collapse: epg.collapse,
      period: period,
    );
  }

  /// Update Total and return the updated value
  double updateTotal(int period) {
    total = items.fold(0.0, (acc, item) => acc + (item.check ? item.getPeriodAmount(period) : 0));
    return total;
  }

  ExpensePredictionGroupTotal copyWith({
    String? name,
    List<ExpensePredictionItem>? items,
    bool? check,
    bool? collapse,
    required int period,
  }) {
    return ExpensePredictionGroupTotal(
      name: name ?? this.name,
      items: items ?? this.items,
      check: check ?? this.check,
      collapse: collapse ?? this.collapse,
      period: period,
    );
  }
}

class ExpensePrediction<T extends ExpensePredictionGroup> implements ModelCommonInterface {
  @override
  String id;
  late DateTime createdAt;
  String name;
  String currencyId;
  Currency? currency;
  List<T> groups;

  ExpensePrediction({
    required this.id,
    required this.name,
    required this.groups,
    this.currencyId = '',
    this.currency,
    DateTime? createdAt,
  }) {
    this.createdAt = createdAt ?? DateTime.now();
  }

  factory ExpensePrediction.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> json) fromJson,
  ) {
    return ExpensePrediction<T>(
      id: json['id'],
      name: json['name'],
      createdAt: Convert.parseDate(json['createdAt'], json),
      groups: List.from(json['groups'] ?? []).map((item) => fromJson(item)).toList(),
      currencyId: json['currencyId'] ?? '',
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{
      'id': id,
      'createdAt': createdAt,
      'name': name,
      'groups': groups.map((item) => item.toJson()).toList(),
      'currencyId': currencyId,
    };
    return data;
  }
}

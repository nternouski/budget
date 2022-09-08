import 'package:budget/model/currency.dart';
import 'package:budget/server/database.dart';

class CurrencyRx {
  static String collectionPath = 'currencies';
  final db = Database();

  Stream<List<Currency>> getCurrencies() {
    return db.getAll(collectionPath).asyncMap((snapshot) => snapshot.map((data) => Currency.fromJson(data)).toList());
  }

  Future<String> create(Currency data) {
    return db.createDoc(collectionPath, data.toJson());
  }

  Future update(Currency data) {
    return db.updateDoc(collectionPath, data.toJson(), data.id);
  }

  Future delete(String id) {
    return db.deleteDoc(collectionPath, id);
  }
}

CurrencyRx currencyRx = CurrencyRx();

import 'package:budget/model/label.dart';
import 'package:budget/server/database/user_rx.dart';
import 'package:budget/server/database.dart';

class LabelRx {
  static String collectionPath = 'labels';
  final db = Database();

  Stream<List<Label>> getLabels(String userId) {
    return db
        .getAll('${UserRx.docPath(userId)}/$collectionPath')
        .asyncMap((snapshot) => snapshot.map((data) => Label.fromJson(data)).toList());
  }

  Future<String> create(Label data, String userId) {
    return db.createDoc('${UserRx.docPath(userId)}/$collectionPath', data.toJson());
  }

  Future update(Label data, String userId) {
    return db.updateDoc('${UserRx.docPath(userId)}/$collectionPath', data.toJson(), data.id);
  }

  Future delete(String id, String userId) {
    return db.deleteDoc('${UserRx.docPath(userId)}/$collectionPath', id);
  }
}

LabelRx labelRx = LabelRx();

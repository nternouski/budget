import 'package:budget/model/label.dart';
import 'package:budget/server/database/user_rx.dart';
import 'package:budget/server/database.dart';
import 'package:rxdart/rxdart.dart';

class LabelRx {
  static String collectionPath = 'labels';
  static String getCollectionPath(String userId) => '${UserRx.docPath(userId)}/$collectionPath';
  final db = Database();

  ValueStream<List<Label>>? _labels;

  Stream<List<Label>> getLabels(String userId) {
    if (_labels != null) return _labels!;
    _labels = db
        .getAll(getCollectionPath(userId))
        .asyncMap((snapshot) => snapshot.map((data) => Label.fromJson(data)).toList())
        .shareValue();
    return _labels!;
  }

  Future<String> create(Label data, String userId) {
    return db.createDoc(getCollectionPath(userId), data.toJson());
  }

  Future update(Label data, String userId) {
    return db.updateDoc(getCollectionPath(userId), data.toJson(), data.id);
  }

  Future delete(String id, String userId) {
    return db.deleteDoc(getCollectionPath(userId), id);
  }
}

LabelRx labelRx = LabelRx();

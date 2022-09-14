import 'package:budget/common/error_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class Database {
  final db = FirebaseFirestore.instance;
  final HandlerError handlerError = HandlerError();

  final verbose = true;

  Database._internal();
  static final Database _singleton = Database._internal();

  factory Database() {
    return _singleton;
  }

  void printMsg(String collectionPath, String msg) {
    if (verbose) debugPrint('---->>>> || $collectionPath | $msg');
  }

  void _printError(String path, String from, String message) {
    debugPrint('==============');
    debugPrint('Error on $path | $from: $message');
    handlerError.setError('Error on $path | $from: $message');
    debugPrint('==============');
  }

  Future<Map<String, dynamic>> getDocFuture(String collectionPath, String id) {
    try {
      return db.collection(collectionPath).doc(id).get().then((snapshot) {
        printMsg(collectionPath, 'GET FUTURE id = $id');
        if (!snapshot.exists) throw Exception('Document Not Exist $collectionPath ID: $id');
        return {'id': snapshot.id, ...(snapshot.data() ?? {})};
      });
    } catch (error) {
      _printError('getDocFuture | Database', collectionPath, 'Error catch: $error');
      throw 'Error on getDocFuture $collectionPath';
    }
  }

  CollectionReference<Map<String, dynamic>> getCollection(String path) {
    return db.collection(path);
  }

  Future<List<String>> getDocIdsOf(String collectionPath, {Query<Map<String, dynamic>>? reference}) {
    try {
      return (reference ?? db.collection(collectionPath)).get().then((snapshots) {
        printMsg(collectionPath, 'GET FUTURE COLLECTION');
        return snapshots.docs.fold<List<String>>([], (acc, doc) => doc.exists ? [...acc, doc.id] : acc);
      });
    } catch (error) {
      _printError('getDocIdsOf | Database', collectionPath, 'Error catch: $error');
      throw 'Error on getDocIdsOf $collectionPath';
    }
  }

  Future<bool> getDocExist(String collectionPath, String id) {
    return db.collection(collectionPath).doc(id).get().then((snapshot) {
      printMsg(collectionPath, 'EXIST DOC $collectionPath/$id');
      return snapshot.exists;
    });
  }

  ValueStream<Map<String, dynamic>> getDoc(String collectionPath, String id) {
    try {
      return db.collection(collectionPath).doc(id).snapshots().asyncMap((snapshot) {
        printMsg(collectionPath, 'GET id = $id');
        if (!snapshot.exists) throw Exception('Document Not Exist $collectionPath ID: $id');
        return {'id': snapshot.id, ...(snapshot.data() ?? {})};
      }).shareValue();
    } catch (error) {
      _printError('getAll | Database', collectionPath, 'Error catch: $error');
      throw 'Error on getAll $collectionPath';
    }
  }

  ValueStream<List<Map<String, dynamic>>> getAll(String collectionPath, {Query<Map<String, dynamic>>? reference}) {
    try {
      return (reference ?? db.collection(collectionPath)).snapshots().asyncMap((snapshot) {
        printMsg(collectionPath, 'GET ALL');
        return snapshot.docs.map((d) => {'id': d.id, ...d.data()}).toList();
      }).shareValue();
    } catch (error) {
      _printError('getAll | Database', collectionPath, 'Error catch: $error');
      throw 'Error on getAll $collectionPath';
    }
  }

  Future<String> createDoc(String collectionPath, Map<String, dynamic> data, {String? id}) async {
    try {
      printMsg(collectionPath, 'CREATE');
      final variable = Map<String, dynamic>.from(data);
      variable.remove('id');
      if (id == null || id == '') {
        final value = await db.collection(collectionPath).add(variable);
        return value.id;
      } else {
        // Ver que nos e haga over wite
        await db.collection(collectionPath).doc(id).set(variable);
        return id;
      }
    } catch (error) {
      _printError('create | Database', '$collectionPath/$id', 'Error catch: $error');
      throw 'Error on create $collectionPath/$id';
    }
  }

  Future<Map<String, dynamic>> updateDoc(String collectionPath, Map<String, dynamic> data, String id) async {
    try {
      printMsg(collectionPath, 'UPDATE');
      final variable = Map<String, dynamic>.from(data);
      variable.remove('id');
      await db.collection(collectionPath).doc(id).update(variable);
      return {'id': id, ...variable};
    } catch (error) {
      _printError('update | Database', '$collectionPath/$id', 'Error catch: $error');
      throw 'Error on update $collectionPath/$id';
    }
  }

  Future<void> deleteDoc(String collectionPath, String id) async {
    try {
      printMsg(collectionPath, 'DELETE');
      await db.collection(collectionPath).doc(id).delete();
    } catch (error) {
      _printError('delete | Database', '$collectionPath/$id', 'Error catch: $error');
      throw 'Error on delete $collectionPath/$id';
    }
  }
}

import 'dart:developer';

import 'package:rxdart/rxdart.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../common/classes.dart';
import '../server/graphql_config.dart';

enum TypeRequest { query, mutation }

class Database<T extends ModelCommonInterface> {
  final GraphQlQuery _queries;
  final String collectionName;
  T Function(Map<String, dynamic> json) constructor;

  final behavior = BehaviorSubject<List<T>>();
  Stream<List<T>> get fetchRx => behavior.stream;

  Database(this._queries, this.collectionName, this.constructor);

  final verbose = true;

  void printMsg(String msg) {
    if (verbose) debugPrint('->> | $collectionName | $msg');
  }

  void _printError(String from, String message) {
    debugPrint('==============');
    debugPrint('Error on $collectionName | $from: $message');
    debugPrint('==============');
  }

  Future<Map<String, dynamic>?> request({
    required TypeRequest type,
    required query,
    required Map<String, dynamic> variable,
    bool throwError = false,
  }) async {
    try {
      QueryResult result;
      if (type == TypeRequest.query) {
        result = await graphQLConfig.clientValueNotifier.value
            .query(QueryOptions(document: gql(query), variables: variable));
      } else {
        result = await graphQLConfig.clientValueNotifier.value
            .mutate(MutationOptions(document: gql(query), variables: variable));
      }
      if (result.hasException) {
        final message = result.exception?.linkException?.originalException?.message;
        if (message is String) _printError('$type | hasException', message);
        for (var error in result.exception?.graphqlErrors ?? []) {
          debugPrint('Error hasException: $error');
        }
      } else if (result.data != null) {
        return result.data;
      }
    } catch (error) {
      _printError('$type | API_client', 'Error catch: $error');
      if (throwError) throw 'Error on $type $collectionName';
    }
    return null;
  }

  getAll() async {
    printMsg('GET ALL');
    final value = await request(type: TypeRequest.query, query: _queries.getAll, variable: {});
    if (value != null && value[collectionName] != null) {
      var t = List<T>.from(value[collectionName].map((t) => constructor(t)).toList());
      behavior.add(t);
    }
  }

  Future<T?> create(T data) async {
    printMsg('CREATE');
    final variable = data.toJson();
    variable.remove('id');
    final value = await request(type: TypeRequest.mutation, query: _queries.create, variable: variable);
    if (value != null && value['action']['returning'] != null) {
      T elementAdded = constructor(value['action']['returning'][0]);
      if (behavior.valueOrNull != null) behavior.add([...List.from(behavior.value), elementAdded]);
      return elementAdded;
    }
    return null;
  }

  Future<T?> update(T data) async {
    printMsg('UPDATE');
    final value = await request(type: TypeRequest.mutation, query: _queries.update, variable: data.toJson());
    if (value != null && value['action']['returning'] != null) {
      T elementUpdated = constructor(value['action']['returning'][0]);
      var data = behavior.hasValue ? behavior.value : List<T>.from([]);
      behavior.add(data.map((v) => v.id == elementUpdated.id ? elementUpdated : v).toList());
      return elementUpdated;
    }
    return null;
  }

  Future<void> delete(String id) async {
    printMsg('DELETE');
    final value = await request(type: TypeRequest.mutation, query: _queries.delete, variable: {'id': id});
    if (value != null) {
      var data = behavior.hasValue ? behavior.value : List<T>.from([]);
      behavior.add(data.where((v) => v.id != id).toList());
    }
  }
}

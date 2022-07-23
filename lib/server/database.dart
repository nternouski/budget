import 'dart:developer';

import 'package:rxdart/rxdart.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../common/classes.dart';
import '../server/graphql_config.dart';

enum TypeRequest { query, mutation }

class Database<T extends ModelCommonInterface> {
  final GraphQlQuery _queries;
  final String collectionName;
  T Function(Map<String, dynamic> json) constructor;

  Database(this._queries, this.collectionName, this.constructor);

  final _behavior = BehaviorSubject<List<T>>();
  Stream<List<T>> get fetchRx => _behavior.stream;

  final verbose = true;

  void printMsg(String msg) {
    if (verbose) print('->> | $collectionName | $msg');
  }

  void _printError(String from, String message) {
    print('==============');
    print("Error $from: $message");
    print('==============');
  }

  Future<Map<String, dynamic>?> request(TypeRequest type, String query, Map<String, dynamic> variable) async {
    try {
      QueryResult result;
      if (type == TypeRequest.query) {
        result = await graphQLConfig.client.query(QueryOptions(document: gql(query), variables: variable));
      } else {
        result = await graphQLConfig.client.mutate(MutationOptions(document: gql(query), variables: variable));
      }
      if (result.hasException) {
        _printError('hasException', result.exception?.linkException?.originalException);
        for (var error in result.exception?.graphqlErrors ?? []) {
          print("Error hasException: $error");
        }
      } else if (result.data != null) {
        return result.data;
      }
    } catch (error) {
      _printError('API_client', 'Error catch: $error');
    }
    return null;
  }

  getAll() async {
    printMsg('GET ALL');
    final value = await request(TypeRequest.query, _queries.getAll, {});
    if (value != null && value[collectionName] != null) {
      var t = List<T>.from(value[collectionName].map((t) => constructor(t)).toList());
      _behavior.add(t);
    }
  }

  create(T data) async {
    printMsg('CREATE');
    final variable = data.toJson();
    variable.remove('id');
    final value = await request(TypeRequest.mutation, _queries.create, variable);
    if (value != null && value['action']['returning'] != null) {
      T elementAdded = constructor(value['action']['returning'][0]);
      _behavior.add([...List.from(_behavior.value), elementAdded]);
    }
  }

  update(T data) async {
    printMsg('UPDATE');
    final value = await request(TypeRequest.mutation, _queries.update, data.toJson());
    if (value != null && value['action']['returning'] != null) {
      T elementUpdated = constructor(value['action']['returning'][0]);
      _behavior.add(_behavior.value.map((v) => v.id == elementUpdated.id ? elementUpdated : v).toList());
    }
  }

  delete(String id) async {
    printMsg('DELETE');
    final value = await request(TypeRequest.mutation, _queries.delete, {'id': id});
    if (value != null) {
      _behavior.add(_behavior.value.where((v) => v.id != id).toList());
    }
  }
}

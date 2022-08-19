import '../common/classes.dart';
import '../common/convert.dart';

enum IntegrationType { wise }

extension ParseToString on IntegrationType {
  String toShortString() {
    return toString().split('.').last;
  }
}

class Integration implements ModelCommonInterface {
  @override
  String id;
  DateTime createdAt;
  IntegrationType integrationType;
  String apiKey;
  String userId;

  Integration({
    required this.id,
    required this.createdAt,
    required this.integrationType,
    required this.apiKey,
    required this.userId,
  });

  factory Integration.wise(String userId) {
    return Integration(
      id: '',
      createdAt: DateTime.now(),
      integrationType: IntegrationType.wise,
      apiKey: '',
      userId: userId,
    );
  }

  factory Integration.fromJson(Map<String, dynamic> json) {
    return Integration(
      id: json['id'],
      createdAt: Convert.parseDate(json['createdAt']),
      integrationType: IntegrationType.values.byName(json['integrationType']),
      apiKey: json['apiKey'],
      userId: json['userId'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{
      'id': id,
      'integrationType': integrationType.name,
      'apiKey': apiKey,
    };
    return data;
  }
}

class IntegrationQueries implements GraphQlQuery {
  @override
  String getAll = r'''
    query getIntegrations {
      integrations {
        id
        createdAt
        integrationType
        apiKey
        userId
      }
    }''';

  @override
  String create = r'''
    mutation addIntegration($integrationType: String!, $apiKey: String!) {
      action: insert_integrations(objects: [{ integrationType: $integrationType, apiKey: $apiKey }]) {
        returning {
          id
          createdAt
          integrationType
          apiKey
          userId
        }
      }
    }''';

  @override
  String update = r'''
    mutation updateIntegration($id: String!, $integrationType: String!, $apiKey: String!) {
      action: update_integrations(where: {id: {_eq: $id}}, _set: { integrationType: $integrationType, apiKey: $apiKey }) {
        returning {
          id
          createdAt
          integrationType
          apiKey
          userId
        }
      }
    }''';

  @override
  String delete = r'''
    mutation deleteIntegration($id: String!) {
      action: delete_integration(id: $id) {
        affected_rows
      }
    }''';
}

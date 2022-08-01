import "package:flutter/material.dart";
import "package:graphql_flutter/graphql_flutter.dart";

// ignore: non_constant_identifier_names
var GRAPHQL_URL = '192.168.0.7:8080/v1/graphql';

class GraphQLConfig {
  final HttpLink _httpLink = HttpLink('http://$GRAPHQL_URL');

  WebSocketLink _wsLink(String token) {
    return WebSocketLink(
      'wss://$GRAPHQL_URL',
      config: SocketClientConfig(
        inactivityTimeout: const Duration(seconds: 15),
        initialPayload: {'Authorization': 'Bearer $token'},
        autoReconnect: true,
      ),
    );
  }

  Link _splitLink(String token) => Link.split((request) => request.isSubscription, _wsLink(token), _httpLink);

  late ValueNotifier<GraphQLClient> clientValueNotifier;
  late GraphQLClient client;

  GraphQLConfig() {
    var token = '';
    final policies = Policies(fetch: FetchPolicy.networkOnly);

    client = GraphQLClient(
      link: AuthLink(getToken: () async => 'Bearer $token').concat(_splitLink(token)),
      cache: GraphQLCache(),
      defaultPolicies: DefaultPolicies(watchQuery: policies, query: policies, mutate: policies),
    );

    clientValueNotifier = ValueNotifier(client);
  }
}

GraphQLConfig graphQLConfig = GraphQLConfig();

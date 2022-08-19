import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

// ignore: non_constant_identifier_names
var GRAPHQL_URL = '192.168.0.7:8080/v1/graphql';

class GraphQLConfig {
  final _policies = Policies(fetch: FetchPolicy.networkOnly);

  Link _splitLink(String token) => Link.split(
        (request) => request.isSubscription,
        WebSocketLink(
          'wss://$GRAPHQL_URL',
          config: const SocketClientConfig(inactivityTimeout: Duration(seconds: 60), autoReconnect: true),
        ),
        HttpLink('http://$GRAPHQL_URL'),
      );

  late ValueNotifier<GraphQLClient> clientValueNotifier;
  late GraphQLClient client;

  GraphQLConfig() {
    client = GraphQLClient(
      link: _splitLink(''),
      cache: GraphQLCache(),
      defaultPolicies: DefaultPolicies(watchQuery: _policies, query: _policies, mutate: _policies),
    );

    clientValueNotifier = ValueNotifier(client);
  }

  Future<void> setToken(String token) async {
    client = GraphQLClient(
      link: AuthLink(getToken: () async => 'Bearer $token').concat(_splitLink(token)),
      cache: GraphQLCache(),
      defaultPolicies: DefaultPolicies(watchQuery: _policies, query: _policies, mutate: _policies),
    );

    clientValueNotifier.value = client;
    // FIXME: VEr porque pasa esto;
    await Future.delayed(const Duration(seconds: 2));
  }
}

GraphQLConfig graphQLConfig = GraphQLConfig();

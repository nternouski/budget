import "package:flutter/material.dart";
import "package:graphql_flutter/graphql_flutter.dart";

class GraphQLConfig {
  final String _token = "your can get it from a secured storage";
  final HttpLink _httpLink = HttpLink('http://192.168.0.7:8080/v1/graphql');
  late ValueNotifier<GraphQLClient> clientValueNotifier;
  late GraphQLClient client;

  GraphQLConfig() {
    final AuthLink authLink = AuthLink(
      getToken: () async => 'Bearer $_token',
    );

    final Link link = authLink.concat(_httpLink);

    final policies = Policies(fetch: FetchPolicy.networkOnly);

    client = GraphQLClient(
      link: link,
      cache: GraphQLCache(),
      defaultPolicies: DefaultPolicies(
        watchQuery: policies,
        query: policies,
        mutate: policies,
      ),
    );

    clientValueNotifier = ValueNotifier(client);
  }
}

GraphQLConfig graphQLConfig = GraphQLConfig();

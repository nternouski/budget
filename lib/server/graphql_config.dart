import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

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
    // var token =
    //     'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Il83R3haNUh5dWVXRlVSeVM3VHFzMCJ9.eyJodHRwczovL2hhc3VyYS5pby9qd3QvY2xhaW1zIjp7IngtaGFzdXJhLWRlZmF1bHQtcm9sZSI6InVzZXIiLCJ4LWhhc3VyYS1hbGxvd2VkLXJvbGVzIjpbInVzZXIiXSwieC1oYXN1cmEtdXNlci1pZCI6Imdvb2dsZS1vYXV0aDJ8MTA0ODM2MjI1MDc1ODk4MTg5OTYxIn0sImdpdmVuX25hbWUiOiJOYWh1ZWwiLCJmYW1pbHlfbmFtZSI6IlRlcm5vdXNraSIsIm5pY2tuYW1lIjoidW5scDkzbmFodWVsdGVyIiwibmFtZSI6Ik5haHVlbCBUZXJub3Vza2kiLCJwaWN0dXJlIjoiaHR0cHM6Ly9saDMuZ29vZ2xldXNlcmNvbnRlbnQuY29tL2EvQUl0YnZtbUFYTlVVLWtXcmljYTVTU1RyZTUxMDRocWRaSTdMdHgtVkQ1QT1zOTYtYyIsImxvY2FsZSI6ImVzLTQxOSIsInVwZGF0ZWRfYXQiOiIyMDIyLTA4LTAyVDE4OjU5OjQ3LjEyM1oiLCJlbWFpbCI6InVubHA5M25haHVlbHRlckBnbWFpbC5jb20iLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiaXNzIjoiaHR0cHM6Ly9kZXYtY3h3c25oYXYudXMuYXV0aDAuY29tLyIsInN1YiI6Imdvb2dsZS1vYXV0aDJ8MTA0ODM2MjI1MDc1ODk4MTg5OTYxIiwiYXVkIjoiOUliaUozNUwxMERCQ3JadFZMUElVeVhhREc3THNybUoiLCJpYXQiOjE2NTk0Njk5MzMsImV4cCI6MTY1OTUwNTkzM30.CreQA2srYvUr-S917TcYBh--enP2JpY9vvA9bT1RVbmrtr8hs7JZlA_WYyFxpzIl918QyZkuhkfRF8uiMC5XmPUDKBKZH7fHWN41rR7xEJFQnNB8d_wgJoTsi944Kb6pklhs-97Ntwz-6tgQTRbjQ9rUDQFO-RYFCi93b9F9F6OSY-t_b154PzVkUOvUJ1Sfq6Q6S6FWrJ9DCIdk2p06X7FRS1QaaAQmG4gVSzsf5VZlkzIqLamRk0ptT7GpUz5aEMJD-BBIH9eQvMALvinwhqDxtcF65LPEbpUq2TwxG-j8chIHoHE56jTAy1KmYSi3h-h5SyNn1rSovb56kJ1ADA';
    var token = '';
    final policies = Policies(fetch: FetchPolicy.networkOnly);

    client = GraphQLClient(
      link: AuthLink(getToken: () async => 'Bearer $token').concat(_splitLink(token)),
      cache: GraphQLCache(),
      defaultPolicies: DefaultPolicies(watchQuery: policies, query: policies, mutate: policies),
    );

    clientValueNotifier = ValueNotifier(client);
  }

  setToken(String token) {
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

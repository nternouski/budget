import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:budget/server/wise_api/helper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HttpService {
  final String baseUrl;
  final String token;

  HttpService(this.baseUrl, this.token);

  Future<dynamic> _get({
    required String endpoint,
    Map<String, dynamic> queryParams = const {},
    Map<String, String> headers = const {},
  }) async {
    var params = queryParams.map((key, value) => MapEntry(key, value.toString()));
    final res = await http.get(Uri.https(baseUrl, endpoint, params), headers: {
      ...headers,
      if (token != '') ...{'Authorization': 'Bearer $token'}
    });
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else if (res.statusCode >= 400 && res.statusCode <= 500) {
      debugPrint('==> Error ${res.statusCode}');
      inspect(jsonDecode(res.body));
      return jsonDecode(res.body);
    } else {
      debugPrint('-------------');
      debugPrint('Failed get: $endpoint');
      debugPrint('-------------');
    }
  }

  Future<dynamic> _post({required String endpoint, Object? body, Map<String, String>? headers}) async {
    final response = await http.post(Uri.https(baseUrl, endpoint), body: body, headers: headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      debugPrint('-------------');
      debugPrint('Failed get: $endpoint');
      debugPrint('-------------');
    }
  }
}

class WiseApi extends HttpService {
  WiseApi(String token) : super('api.sandbox.transferwise.tech', token);

  Future<List<WiseProfile>> _fetchProfiles() async {
    final response = await _get(endpoint: '/v2/profiles');
    return List.from(response).map((p) => WiseProfile.fromJson(p)).toList();
  }

  Future<List<WiseProfileBalance>> fetchBalance() async {
    var result = await Future.wait(
      (await _fetchProfiles()).map((profile) {
        return _get(endpoint: '/v4/profiles/${profile.id}/balances', queryParams: {'types': 'STANDARD'}).then(
          (balancesJson) => WiseProfileBalance(
            profile: profile,
            balances: List.from(balancesJson).map((b) => WiseBalance.fromJson(b, profile.id)).toList(),
          ),
        );
      }),
    );
    return result;
  }

  Future<dynamic> fetchRates(String source, String target) async {
    return await _get(endpoint: '/v1/rates', queryParams: {'source': source, 'target': target});
  }

  Future<List<WiseTransactions>> fetchBalanceStatements({
    required WiseBalance balance,
    required DateTime intervalStart,
    String? walletId,
  }) async {
    final response = await _get(
      endpoint: '/v1/profiles/${balance.profileId}/balance-statements/${balance.id}/statement.json',
      queryParams: {
        'currency': balance.currency,
        'intervalStart': '2022-07-01T00:00:00.000Z',
        'intervalEnd': '2022-08-10T23:59:59.999Z',
        'type': 'COMPACT'
      },
    );
    return List.from(response['transactions']).map((t) => WiseTransactions.fromJson(t, walletId ?? '')).toList();
  }

  Future<dynamic> fetchTransfers({
    int? offset = 0,
    int? limit = 100,
    int? profile = 16550506,
    String? status = 'funds_refunded',
    DateTime? createdDateStart,
  }) async {
    // sourceCurrency=EUR
    List<dynamic> response = await _get(
      endpoint: '/v1/transfers',
      queryParams: {
        'offset': offset,
        'limit': limit,
        'profile': profile,
        // 'status': status,
        // 'createdDateStart': '2022-01-01',
      },
    );
    return response;
  }
}

import 'dart:async';
import 'package:intl/intl.dart';

import 'package:budget/model/wallet.dart';
import 'package:budget/server/http_service.dart';
import 'package:budget/server/wise_api/helper.dart';

class WiseApi extends HttpService {
  WiseApi(String token) : super('api.sandbox.transferwise.tech', token);

  Future<List<WiseProfile>> _fetchProfiles() async {
    final response = await get(endpoint: '/v2/profiles');
    return List.from(response).map((p) => WiseProfile.fromJson(p)).toList();
  }

  Future<List<WiseProfileBalance>> fetchBalance() async {
    var result = await Future.wait(
      (await _fetchProfiles()).map((profile) {
        return get(endpoint: '/v4/profiles/${profile.id}/balances', queryParams: {'types': 'STANDARD'}).then(
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
    return await get(endpoint: '/v1/rates', queryParams: {'source': source, 'target': target});
  }

  Future<List<WiseStatementTransactions>> fetchBalanceStatements({
    required WiseBalance balance,
    required DateTime intervalStart,
    String? walletId,
  }) async {
    final response = await get(
      endpoint: '/v1/profiles/${balance.profileId}/balance-statements/${balance.id}/statement.json',
      queryParams: {
        'currency': balance.currency,
        'intervalStart': '2022-07-01T00:00:00.000Z',
        'intervalEnd': '2022-08-10T23:59:59.999Z',
        'type': 'COMPACT'
      },
    );
    return List.from(response['transactions'])
        .map((t) => WiseStatementTransactions.fromJson(t, walletId ?? ''))
        .toList();
  }

  Future<List<WiseTransactions>> fetchTransfers({
    required DateTime createdDateStart,
    required Wallet wallet,
    int? offset = 0,
    int? limit = 100,
  }) async {
    Map<String, dynamic> queryParams = {
      'offset': offset,
      'limit': limit,
      'createdDateStart': DateFormat('yyyy-MM-dd').format(createdDateStart),
    };
    if (wallet.currency != null) queryParams['sourceCurrency'] = wallet.currency!.symbol;
    List<dynamic> response = await get(endpoint: '/v1/transfers', queryParams: queryParams);
    return List.from(response).map((t) => WiseTransactions.fromJson(t, wallet)).toList();
  }
}

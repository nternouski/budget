import 'dart:async';
import 'dart:developer';
import 'package:budget/model/currency.dart';
import 'package:budget/server/http_service.dart';
import 'package:budget/server/wise_api/wise_api.dart';

class Rate {
  final String provider;
  final double rate;
  const Rate(this.provider, this.rate);
}

class CurrencyRateApi {
  final defaultHttp = HttpService('cdn.jsdelivr.net', '');
  final arsToUsdHttp = HttpService('criptoya.com', '');

  CurrencyRateApi();

  Future<List<Rate?>> fetchRates(CurrencyRate cr, WiseApi? wiseApi) async {
    return Future.wait([
      _fetchDefault(cr),
      if (wiseApi != null) wiseApi.fetchRates(cr).then((r) => r != null ? Rate('Wise', r.rate) : null),
      if (cr.currencyFrom.symbol == 'ARS' && cr.currencyTo.symbol == 'USD') _fetchArsToUsd()
    ]).onError((error, stackTrace) {
      inspect(error);
      inspect(stackTrace);
      return [];
    });
  }

  Future<Rate> _fetchDefault(CurrencyRate cr) async {
    final to = cr.currencyTo.symbol.toLowerCase();
    final from = cr.currencyFrom.symbol.toLowerCase();

    const baseURL = '/gh/fawazahmed0/currency-api@1/latest/currencies';
    final rate = await defaultHttp.get(endpoint: '$baseURL/$to/$from.json').then((response) => response[from] ?? -1);

    return Rate('Default', rate);
  }

  Future<Rate> _fetchArsToUsd() async {
    final rate = await arsToUsdHttp.get(endpoint: '/api/dolar').then((response) {
      return double.tryParse(response['blue'].toString()) ?? -1.0;
    });
    return Rate('criptoya', rate);
  }
}

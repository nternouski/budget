import 'dart:async';
import 'package:budget/model/currency.dart';
import 'package:budget/server/http_service.dart';

class CurrencyRateApi extends HttpService {
  final commonBaseURL = '/gh/fawazahmed0/currency-api@1/latest/currencies';
  CurrencyRateApi() : super('cdn.jsdelivr.net', '');

  Future<double> fetchRate(CurrencyRate cr) async {
    final to = cr.currencyTo.symbol.toLowerCase();
    final from = cr.currencyFrom.symbol.toLowerCase();
    return get(endpoint: '$commonBaseURL/$to/$from.json').then((response) => response[from] ?? 0.0);
  }
}

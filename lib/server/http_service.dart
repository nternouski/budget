import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HttpService {
  final String baseUrl;
  final String token;

  HttpService(this.baseUrl, this.token);

  @protected
  Future<dynamic> get({
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
      return jsonDecode(res.body);
    } else {
      debugPrint('-------------');
      debugPrint('Failed get: $endpoint');
      debugPrint('-------------');
    }
  }

  @protected
  Future<dynamic> post({required String endpoint, Object? body, Map<String, String>? headers}) async {
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

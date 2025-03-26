import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mobile/config/app_config.dart';
import 'package:mobile/models/currency.dart';
import 'package:mobile/tools/token_handler.dart';

class CurrencyRepository {
  static final _currencyUrl = AppConfig().currencyApiUrl;

  static Future<CurrencyList> fetch(CurrencyType type) async {
    final token = await TokenHandler.loadToken();
    final response = await http.get(
      Uri.parse('$_currencyUrl/currencies?currency_type=${type.toString()}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 204) {
      return CurrencyList(currencies: []);
    }

    if (response.statusCode != 200) {
      throw Exception('Failed to load fiat currencies: ${response.statusCode}');
    }

    final Map<String, dynamic> data = json.decode(response.body);
    return CurrencyList.fromJson(data);
  }

  static Future<CurrencyList> fetchAllFiat() async {
    return await fetch(CurrencyType.FIAT);
  }

  static Future<CurrencyList> fetchAllCrypto() async {
    return await fetch(CurrencyType.CRYPTO);
  }

  static Future<CurrencyList> fetchAll() async {
    final List<Currency> currencies = [
      ...(await fetchAllFiat()).currencies,
      ...(await fetchAllCrypto()).currencies,
    ];

    currencies.sort((a, b) => a.name.compareTo(b.name));

    return CurrencyList(currencies: currencies);
  }
}

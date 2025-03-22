import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mobile/config/app_config.dart';
import 'package:mobile/models/crypto_currency.dart';
import 'package:mobile/models/fiat_currency.dart';
import 'package:mobile/tools/token_handler.dart';

class MarketRepository {
  static Future<CryptoCurrencyList> fetchCryptocurrencies() async {
    final token = await TokenHandler.loadToken();
    final cryptoApiUrl = AppConfig().cryptoApiUrl;

    final response = await http.get(
      Uri.parse('$cryptoApiUrl/coins?currency=usd'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return CryptoCurrencyList.fromJson(data);
    } else {
      throw Exception('Failed to load cryptocurrencies');
    }
  }

  static Future<FiatCurrencyList> fetchFiatCurrencies() async {
    final token = await TokenHandler.loadToken();
    final fiatApiUrl = AppConfig().fiatApiUrl;

    final response = await http.get(
      Uri.parse('$fiatApiUrl/currencies?currency_type=FIAT'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return FiatCurrencyList.fromJson(data);
    } else {
      throw Exception('Failed to load fiat currencies');
    }
  }
}

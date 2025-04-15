import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mobile/config/app_config.dart';
import 'package:mobile/models/coin.dart';
import 'package:mobile/models/currency.dart';
import 'package:mobile/models/wallet.dart';
import 'package:mobile/tools/token_handler.dart';

class MarketRepository {
  static Future<CoinList> fetchCryptoCurrencies(String currency) async {
    final token = await TokenHandler.loadToken();
    final cryptoApiUrl = AppConfig().cryptoApiUrl;

    final response = await http.get(
      Uri.parse('$cryptoApiUrl/coins?currency=$currency'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load crypto currencies: ${response.statusCode}',
      );
    }

    final Map<String, dynamic> data = json.decode(response.body);
    return CoinList.fromJson(data);
  }

  static Future<CurrencyList> fetchAllFiatCurrencies() async {
    final token = await TokenHandler.loadToken();
    final fiatApiUrl = AppConfig().currencyApiUrl;

    final response = await http.get(
      Uri.parse(
        '$fiatApiUrl/currencies?currency_type=${CurrencyType.FIAT.toString()}',
      ),
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

  static Future<CurrencyList> fetchUserFiatCurrencies() async {
    final token = await TokenHandler.loadToken();
    final walletApiUrl = AppConfig().walletApiUrl;

    final response = await http.get(
      Uri.parse(walletApiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 204) {
      return CurrencyList(currencies: []);
    }

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load user fiat currencies: ${response.statusCode}',
      );
    }

    final Map<String, dynamic> data = json.decode(response.body);
    final walletList = WalletList.fromJson(data);

    final List<Wallet> fiatWallets =
        walletList.wallets.where((wallet) => !wallet.isCrypto).toList();

    fiatWallets.sort((a, b) => a.id.compareTo(b.id));

    final Set<String> uniqueFiatCurrencies =
        fiatWallets.map((wallet) => wallet.currency).toSet();

    final List<Currency> fiatCurrencies =
        uniqueFiatCurrencies
            .map((currencyName) => Currency(name: currencyName.toLowerCase()))
            .toList();

    return CurrencyList(currencies: fiatCurrencies);
  }
}

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/config/app_config.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/models/crypto_currency.dart';
import 'package:mobile/models/fiat_currency.dart';
import 'package:mobile/models/wallet.dart';
import 'package:mobile/tools/token_handler.dart';

class CurrencyRepository {
  static Future<CryptoCurrencyList> fetchCryptoCurrencies(
    BuildContext context,
    String currency,
  ) async {
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
        AppLocalizations.of(context).translate('crypto_currency_loading_error'),
      );
    }

    final Map<String, dynamic> data = json.decode(response.body);
    return CryptoCurrencyList.fromJson(data);
  }

  static Future<FiatCurrencyList> fetchAllFiatCurrencies(
    BuildContext context,
  ) async {
    final token = await TokenHandler.loadToken();
    final fiatApiUrl = AppConfig().fiatApiUrl;

    final response = await http.get(
      Uri.parse('$fiatApiUrl/currencies?currency_type=FIAT'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 204) {
      return FiatCurrencyList(currencies: []);
    }

    if (response.statusCode != 200) {
      throw Exception(
        AppLocalizations.of(context).translate('fiat_currency_loading_error'),
      );
    }

    final Map<String, dynamic> data = json.decode(response.body);
    return FiatCurrencyList.fromJson(data);
  }

  static Future<FiatCurrencyList> fetchUserFiatCurrencies(
    BuildContext context,
  ) async {
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
      return FiatCurrencyList(currencies: []);
    }

    if (response.statusCode != 200) {
      throw Exception(
        AppLocalizations.of(context).translate('fiat_currency_loading_error'),
      );
    }

    final Map<String, dynamic> data = json.decode(response.body);
    final walletList = WalletList.fromJson(data);

    final List<Wallet> fiatWallets =
        walletList.wallets.where((wallet) => !wallet.isCrypto).toList();

    fiatWallets.sort((a, b) => a.id.compareTo(b.id));

    final Set<String> uniqueFiatCurrencies =
        fiatWallets.map((wallet) => wallet.currency).toSet();

    final List<FiatCurrency> fiatCurrencies =
        uniqueFiatCurrencies
            .map(
              (currencyName) => FiatCurrency(name: currencyName.toLowerCase()),
            )
            .toList();

    return FiatCurrencyList(currencies: fiatCurrencies);
  }
}

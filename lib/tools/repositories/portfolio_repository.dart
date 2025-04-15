import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/config/app_config.dart';
import 'package:mobile/models/crypto_statistic.dart';
import 'package:mobile/tools/token_handler.dart';

class PortfolioRepository {
  static Future<PortfolioDiversityResponse> fetchPortfolioDiversity(String userId, String currency) async {
    final token = await TokenHandler.loadToken();
    final apiBaseUrl = AppConfig().portfolioApiUrl;

    final response = await http.get(
      Uri.parse('$apiBaseUrl/?user_id=$userId&currency=$currency'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 204) {
      return PortfolioDiversityResponse(
        calculationFiatCurrency: currency,
        cryptoWalletsStatistics: [],
      );
    }

    if (response.statusCode != 200) {
      throw Exception('Failed to load portfolio diversity: ${response.statusCode}');
    }

    final Map<String, dynamic> data = json.decode(response.body);
    return PortfolioDiversityResponse.fromJson(data);
  }
}

class PortfolioDiversityResponse {
  final String calculationFiatCurrency;
  final List<CryptoStatistic> cryptoWalletsStatistics;

  PortfolioDiversityResponse({
    required this.calculationFiatCurrency,
    required this.cryptoWalletsStatistics,
  });

  factory PortfolioDiversityResponse.fromJson(Map<String, dynamic> json) {
    return PortfolioDiversityResponse(
      calculationFiatCurrency: json['calculation_fiat_currency'],
      cryptoWalletsStatistics: (json['crypto_wallets_statistics'] as List)
          .map((e) => CryptoStatistic.fromJson(e))
          .toList(),
    );
  }
}
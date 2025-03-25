import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mobile/config/app_config.dart';
import 'package:mobile/models/wallet.dart';
import 'package:mobile/tools/token_handler.dart';

class WalletRepository {
  static final String _baseUrl = AppConfig().walletApiUrl;

  static Future<List<Wallet>> fetchAll() async {
    try {
      final token = await TokenHandler.loadToken();
      final response = await http.get(
        Uri.parse("$_baseUrl"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 204) {
        return List.empty();
      }

      if (response.statusCode != 200) {
        throw Exception("Failed to fetch wallets: ${response.statusCode}");
      }

      final List<dynamic> data = json.decode(response.body)['wallets'];
      return data.map((wallet) => Wallet.fromJson(wallet)).toList();
    } catch (e) {
      throw Exception("Error in fetchAllWallets: $e");
    }
  }

  static Future<Wallet> fetchById(String id) async {
    try {
      final token = await TokenHandler.loadToken();
      final response = await http.get(
        Uri.parse("$_baseUrl/$id"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to fetch wallet by ID: ${response.statusCode}");
      }

      final Map<String, dynamic> data = json.decode(response.body);
      return Wallet.fromJson(data);
    } catch (e) {
      throw Exception("Error in fetchWalletById: $e");
    }
  }

  static Future<Wallet> create(Map<String, dynamic> walletData) async {
    try {
      final token = await TokenHandler.loadToken();
      final response = await http.post(
        Uri.parse("$_baseUrl/wallets"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(walletData),
      );

      if (response.statusCode != 201) {
        throw Exception("Failed to create wallet: ${response.statusCode}");
      }

      final Map<String, dynamic> data = json.decode(response.body);
      return Wallet.fromJson(data);
    } catch (e) {
      throw Exception("Error in createWallet: $e");
    }
  }

  static Future<void> update(Map<String, dynamic> walletData) async {
    try {
      final token = await TokenHandler.loadToken();
      final response = await http.put(
        Uri.parse("$_baseUrl/${walletData['id']}"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(walletData),
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to update wallet: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error in updateWallet: $e");
    }
  }

  static Future<void> delete(String id) async {
    try {
      final token = await TokenHandler.loadToken();
      final response = await http.delete(
        Uri.parse("$_baseUrl/$id"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to delete wallet: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error in deleteWallet: $e");
    }
  }
}

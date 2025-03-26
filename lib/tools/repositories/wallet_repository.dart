import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mobile/config/app_config.dart';
import 'package:mobile/models/wallet.dart';
import 'package:mobile/tools/token_handler.dart';

class WalletRepository {
  static final String _walletsUrl = AppConfig().walletApiUrl;

  static Future<List<Wallet>> fetchAll() async {
    try {
      final token = await TokenHandler.loadToken();
      final response = await http.get(
        Uri.parse("$_walletsUrl"),
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
      final List<Wallet> result =
          data.map((wallet) => Wallet.fromJson(wallet)).toList();
      result.sort((w1, w2) => w1.currency.compareTo(w2.currency));

      return result;
    } catch (e) {
      throw Exception("Error in fetchAllWallets: $e");
    }
  }

  static Future<Wallet> fetchById(String id) async {
    try {
      final token = await TokenHandler.loadToken();
      final response = await http.get(
        Uri.parse("$_walletsUrl/wallet/$id"),
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

  static Future<Wallet> create(Map<String, dynamic> newWallet) async {
    try {
      final token = await TokenHandler.loadToken();
      final response = await http.post(
        Uri.parse("$_walletsUrl/"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(newWallet),
      );

      if (response.statusCode != 200) {
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
        Uri.parse("$_walletsUrl/"),
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
        Uri.parse("$_walletsUrl/?wallet_id=$id"),
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

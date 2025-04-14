import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/config/app_config.dart';
import 'package:mobile/tools/api_servicer/api_interface.dart';
import 'package:mobile/tools/token_handler.dart';

class WalletApiService extends apiCalls {
  final String _baseUrl = AppConfig().walletApiUrl;

  @override
  Future<Map<String, dynamic>> create(
    Map<String, dynamic> dataObject,
    BuildContext context,
  ) async {
    try {
      final token = await TokenHandler.loadToken();
      final response = await http.post(
        Uri.parse("$_baseUrl"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(dataObject),
      );
      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to create wallet: ${response.body}");
      }
    } catch (e) {
      debugPrint("Error in create: $e");
      throw Exception(e);
    }
  }

  @override
  Future<Map<String, dynamic>> delete(objectId, BuildContext context) async {
    try {
      final token = await TokenHandler.loadToken();
      final response = await http.delete(
        Uri.parse("$_baseUrl/$objectId"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to delete wallet: ${response.body}");
      }
    } catch (e) {
      debugPrint("Error in delete: $e");
      throw Exception(e);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> read(BuildContext context) async {
    try {
      final token = await TokenHandler.loadToken();
      final response = await http.get(
        Uri.parse("$_baseUrl"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic> && data.containsKey('wallets')) {
          return (data['wallets'] as List)
              .map((item) => item as Map<String, dynamic>)
              .toList();
        } else {
          throw Exception("Unexpected response format: $data");
        }
      } else {
        throw Exception("Failed to fetch wallets: ${response.body}");
      }
    } catch (e) {
      debugPrint("Error in WalletApiService.read: $e");
      throw Exception("Error reading wallets: $e");
    }
  }

  @override
  Future<Map<String, dynamic>> readById({
    id = -1,
    required BuildContext context,
  }) async {
    try {
      final token = await TokenHandler.loadToken();
      final response = await http.get(
        Uri.parse("$_baseUrl/$id"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to fetch wallet by ID: ${response.body}");
      }
    } catch (e) {
      debugPrint("Error in readById: $e");
      throw Exception(e);
    }
  }

  @override
  Future<void> update(
    Map<String, dynamic> dataObject,
    BuildContext context,
  ) async {
    try {
      final token = await TokenHandler.loadToken();
      final response = await http.put(
        Uri.parse("$_baseUrl/${dataObject['id']}"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(dataObject),
      );
      if (response.statusCode == 200) {
        debugPrint("Wallet updated successfully");
      } else {
        throw Exception("Failed to update wallet: ${response.body}");
      }
    } catch (e) {
      debugPrint("Error in update: $e");
      throw Exception(e);
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/config/app_config.dart';
import 'package:mobile/tools/token_handler.dart';

class OrderApiService {
  final String _baseUrl = AppConfig().oderApiUrl;
  static Map<String, String> _headers(String token) => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  /// Create a new order
  Future<Map<String, dynamic>> createOrder({
    required double nominal,
    required double price,
    required double cashQuantity,
    required String type, // ORDER_TYPE_INSTANT / ORDER_TYPE_PENDING
    required String side, // ORDER_SIDE_BUY / ORDER_SIDE_SELL
    required String currencyTarget,
    required String currencyUsedWalletId,
  }) async {
    final url = Uri.parse('$_baseUrl/');
    final body = jsonEncode({
      'nominal': '$nominal',
      'cash_quantity': '$cashQuantity',
      'price': '$price',
      'type': type,
      'side': side,
      'currency_target': currencyTarget,
      'currency_used_wallet_id': currencyUsedWalletId,
    });

    final token = await TokenHandler.loadToken();
    if (token == null) {
      throw Exception('Token is null');
    }

    final response = await http.post(url, headers: _headers(token), body: body);

    if (response.statusCode == 307 || response.statusCode == 308) {
      final redirectUrl = response.headers['location'];
      if (redirectUrl != null) {
        final redirectedResponse = await http.post(
          Uri.parse(redirectUrl),
          headers: _headers(token),
          body: body,
        );
        return _handleResponse(redirectedResponse);
      }
    }

    return _handleResponse(response);
  }

  /// Get a single order by ID
  Future<Map<String, dynamic>> getOrder({required String orderId}) async {
    final url = Uri.parse('$_baseUrl?order_id=$orderId');
    final token = await TokenHandler.loadToken();
    if (token == null) {
      throw Exception('Token is null');
    }
    final response = await http.get(url, headers: _headers(token));
    return _handleResponse(response);
  }

  /// Get list of orders (with optional filters)
  Future<List<dynamic>> getOrders({
    String? userId,
    String? walletId,
    String? orderStatus,
    String? orderType,
    String? side,
  }) async {
    final uri = Uri.parse('$_baseUrl/orders').replace(
      queryParameters: {
        if (userId != null) 'user_id': userId,
        if (walletId != null) 'wallet_id': walletId,
        if (orderStatus != null) 'order_status': orderStatus,
        if (orderType != null) 'order_type': orderType,
        if (side != null) 'side': side,
      },
    );
    final token = await TokenHandler.loadToken();
    if (token == null) {
      throw Exception('Token is null');
    }
    final response = await http.get(uri, headers: _headers(token));
    final data = _handleResponse(response);
    return data['orders'] ?? [];
  }

  /// Delete an order by ID
  Future<Map<String, dynamic>> deleteOrder({required String orderId}) async {
    final url = Uri.parse('$_baseUrl?order_id=$orderId');
    final token = await TokenHandler.loadToken();
    if (token == null) {
      throw Exception('Token is null');
    }
    final response = await http.delete(url, headers: _headers(token));
    return _handleResponse(response);
  }

  /// Handle HTTP response uniformly
  static Map<String, dynamic> _handleResponse(http.Response response) {
    final Map<String, dynamic> data = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw Exception(
        'Request failed [${response.statusCode}]: ${data['detail'] ?? response.body}',
      );
    }
  }
}

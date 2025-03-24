import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/config/app_config.dart';
import 'package:mobile/tools/api_servicer/api_interface.dart';
import 'package:mobile/tools/token_handler.dart';

class UserApiService extends apiCalls {
  final String _baseUrl = AppConfig().userApiUrl;

  @override
  Future<Map<String, dynamic>> create(
    Map<String, dynamic> dataObject,
    BuildContext context,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> delete(objectId, BuildContext context) {
    throw UnimplementedError();
  }

  @override
  Future<List> read(BuildContext context) async {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> readById({
    id = -1,
    required BuildContext context,
  }) async {
    final token = await TokenHandler.loadToken();
    final response = await http.get(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      return json.decode(response.body);
    } else if (response.statusCode == 401) {
      TokenHandler.logout(context);
    }
    throw Exception('Nie udało się pobrać danych profilu');
  }

  @override
  Future<void> update(
    Map<String, dynamic> dataObject,
    BuildContext context,
  ) async {
      final token = await TokenHandler.loadToken();
      final response = await http.put(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(dataObject),
      );
      if (response.statusCode == 200) {
        return;
      } else if (response.statusCode == 401)
        TokenHandler.logout(context);
      if (response.statusCode != 200) {
        throw Exception(
          'Błąd podczas aktualizacji danych: ${response.statusCode}',
        );
      }  
  }

  Future<void> updatePassword(
    Map<String, dynamic> dataObject,
    BuildContext context,
  ) async {
    final token = await TokenHandler.loadToken();
    final response = await http.put(
      Uri.parse('${_baseUrl}update-password'),
      headers: {
        "Content-Type": "application/json",
        'Authorization': "Bearer $token",
      },
      body: json.encode(dataObject),
    );

    if (response.statusCode == 200 &&
        json.decode(response.body)["success"] == true) {
      return;
    } else if (response.statusCode == 400) {
      throw ErrorDescription("invalid_old_password");
    } else if (response.statusCode == 401) {
      TokenHandler.logout(context);
    } else {
      throw ErrorDescription("change_password_fail");
    }
  }
}

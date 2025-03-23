import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/tools/api_servicer/api_interface.dart';
import 'package:mobile/tools/token_handler.dart';
import 'package:mobile/views/account_view.dart';

class UserApiService extends apiCalls {
  final String _baseUrl = 'http://10.0.2.2:80/api/user/';

  @override
  Future<Map<String, dynamic>> create(Map<String, dynamic> dataObject) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> delete(objectId) {
    throw UnimplementedError();
  }

  @override
  Future<List> read() async {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> readById({id = -1}) async {
    try {
      final token = await TokenHandler.loadToken();
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
          'Błąd podczas pobierania danych: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Nie udało się pobrać danych profilu: $e');
    }
  }

  @override
  Future<void> update(Map<String, dynamic> dataObject) async {
    try {
      final token = await TokenHandler.loadToken();
      final response = await http.put(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(dataObject),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Błąd podczas aktualizacji danych: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Nie udało się zaktualizować danych profilu: $e');
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
      body: json.encode(dataObject)
    );

    if (response.statusCode == 200 && json.decode(response.body)["success"] == true) {
      return;
    } else if (response.statusCode == 400) {
      throw ErrorDescription("invalid_old_password");
    } else if (response.statusCode == 401) {
      AccountView.logout(context);
    } else {
      throw ErrorDescription("change_password_fail");
    }
  }
}

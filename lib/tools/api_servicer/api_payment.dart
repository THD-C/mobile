import 'dart:convert';
import 'dart:ui';

import 'package:logger/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/main.dart';
import 'package:mobile/tools/api_servicer/api_interface.dart';
import 'package:mobile/tools/token_handler.dart';

class PaymentApiService extends apiCalls {
  final String _baseUrl = 'http://10.0.2.2:80/api/payments/';
  final String _appLanguageCode = window.locale.languageCode;

  @override
  Future<String> donate(Map<String, dynamic> dataObject) async {
    try {
      final token = await TokenHandler.loadToken();
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Origin': '$baseURL/$_appLanguageCode',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(dataObject),
      );

      if (response.statusCode != 200) {
        Logger().e('$response');
        throw Exception(
          'Błąd podczas generowania linku do płatności: ${response.statusCode}',
        );
      }

      final responseData = jsonDecode(response.body);

      return responseData[0]['session_url'].toString();
    } catch (e) {
      Logger().e('$e');
      throw Exception('$e');
    }
  }

  @override
  Future<Map<String, dynamic>> create(
    Map<String, dynamic> dataObject,
    BuildContext context,
  ) {
    // TODO: implement create
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> delete(objectId, BuildContext context) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future<List> read(BuildContext context) {
    // TODO: implement read
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> readById({
    id = 0,
    required BuildContext context,
  }) {
    // TODO: implement readById
    throw UnimplementedError();
  }

  @override
  Future<void> update(Map<String, dynamic> dataObject, BuildContext context) {
    // TODO: implement update
    throw UnimplementedError();
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/main.dart';
import 'package:mobile/tools/token_handler.dart';

class EditProfileDialog extends StatefulWidget {
  const EditProfileDialog({super.key});

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  String _token = "";
  late final TextEditingController emailController;
  late final TextEditingController nameController;
  late final TextEditingController surnameController;
  late final TextEditingController streetController;
  late final TextEditingController buildingController;
  late final TextEditingController cityController;
  late final TextEditingController postalCodeController;
  late final TextEditingController countryController;

  @override
  Future<void> initState() {
    _token = (TokenHandler.loadToken())!;
    final apiResponse = await http.get(
      Uri.parse('$baseURL/api/user/'),
      headers: {
        'Content-Type': 'application/json',
        "Authorization": "Bearer $_token",
      },
    );

    if (apiResponse.statusCode != 200) {
      Navigator.pop(context);
    }
    super.initState();
    final responseBody = jsonDecode(apiResponse.body);

    emailController = TextEditingController(text: responseBody["email"]);
    nameController = TextEditingController(text: responseBody["name"]);
    surnameController = TextEditingController(text: responseBody["surname"]);
    streetController = TextEditingController(text: responseBody["street"]);
    buildingController = TextEditingController(text: responseBody["building"]);
    cityController = TextEditingController(text: responseBody["city"]);
    postalCodeController = TextEditingController(
      text: responseBody["postalCode"],
    );
    countryController = TextEditingController(text: responseBody["country"]);
  }

  @override
  void dispose() {
    emailController.dispose();
    nameController.dispose();
    surnameController.dispose();
    streetController.dispose();
    buildingController.dispose();
    cityController.dispose();
    postalCodeController.dispose();
    countryController.dispose();
    super.dispose();
  }

  Future<int> _sendUpdateData(Map<String, String> data) async {
    final apiResponse = await http.put(
      Uri.parse('$baseURL/api/user/'),
      headers: {
        'Content-Type': 'application/json',
        "Authorization": "Bearer $_token",
      },
      body: data,
    );
    if (apiResponse.statusCode != 200) {
      return apiResponse.statusCode;
    }

    return 200;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edytuj dane konta'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Imię'),
            ),
            TextField(
              controller: surnameController,
              decoration: const InputDecoration(labelText: 'Nazwisko'),
            ),
            TextField(
              controller: streetController,
              decoration: const InputDecoration(labelText: 'Ulica'),
            ),
            TextField(
              controller: buildingController,
              decoration: const InputDecoration(labelText: 'Numer budynku'),
            ),
            TextField(
              controller: cityController,
              decoration: const InputDecoration(labelText: 'Miasto'),
            ),
            TextField(
              controller: postalCodeController,
              decoration: const InputDecoration(labelText: 'Kod pocztowy'),
            ),
            TextField(
              controller: countryController,
              decoration: const InputDecoration(labelText: 'Kraj'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Anuluj'),
        ),
        FilledButton(
          onPressed: () async {
            // Zbieramy zaktualizowane dane
            final updatedData = {
              "email": emailController.text,
              "name": nameController.text,
              "surname": surnameController.text,
              "street": streetController.text,
              "building": buildingController.text,
              "city": cityController.text,
              "postal_code": postalCodeController.text,
              "country": countryController.text,
            };

            int result = await _sendUpdateData(updatedData);
            if (result == 200) {
              Navigator.pop(context, true);
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Wystąpił błąd podczas aktualizacji danych"),
              ),
            );
          },
          child: const Text('Zapisz'),
        ),
      ],
    );
  }
}

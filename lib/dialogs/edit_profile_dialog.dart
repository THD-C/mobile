import 'package:flutter/material.dart';
import 'package:mobile/tools/api_servicer/api_user.dart';

class EditProfileDialog extends StatefulWidget {
  const EditProfileDialog({super.key});

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  late final TextEditingController emailController = TextEditingController();
  late final TextEditingController nameController = TextEditingController();
  late final TextEditingController surnameController = TextEditingController();
  late final TextEditingController streetController = TextEditingController();
  late final TextEditingController buildingController = TextEditingController();
  late final TextEditingController cityController = TextEditingController();
  late final TextEditingController postalCodeController = TextEditingController();
  late final TextEditingController countryController = TextEditingController();

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

   _fetchUserData();
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

  Future<void> _fetchUserData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      
      var response = await UserApiService().readById();

      setState(() {
        emailController.text = response['email'] ?? '';
        nameController.text = response['name'] ?? '';
        surnameController.text = response['surname'] ?? '';
        streetController.text = response['street'] ?? '';
        buildingController.text = response['building'] ?? '';
        cityController.text = response['city'] ?? '';
        postalCodeController.text = response['postal_code'] ?? '';
        countryController.text = response['country'] ?? '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Błąd podczas pobierania danych: $e';
        _isLoading = false;
      });
    }
  }

Future<void> _saveUserData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final updatedData = {
        'email': emailController.text,
        'name': nameController.text,
        'surname': surnameController.text,
        'street': streetController.text,
        'building': buildingController.text,
        'city': cityController.text,
        'postal_code': postalCodeController.text,
        'country': countryController.text,
      };
      
      await UserApiService().update(updatedData);

      
      // Zamknij dialog z sygnałem sukcesu
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Błąd podczas zapisywania danych: $e';
        _isLoading = false;
      });
    }
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
            _saveUserData();
          },
          child: const Text('Zapisz'),
        ),
      ],
    );
  }
}

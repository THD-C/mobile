import 'package:flutter/material.dart';
import 'package:mobile/l10n/app_localizations.dart';
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
  late final TextEditingController postalCodeController =
      TextEditingController();
  late final TextEditingController countryController = TextEditingController();

  bool _isLoading = true;
  String? _errorMessage;
  String? _emailError;

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
        _errorMessage =
            '${AppLocalizations.of(context).translate("edit_dialog_fetch_data_error")}: $e';
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
        _errorMessage =
            '${AppLocalizations.of(context).translate("edit_dialog_update_data_error")}: $e';
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(
              context,
            ).translate("account_data_update_failed"),
          ),
        ),
      );
    }
  }

  void validateEmail() {
    setState(() {
      // Sprawdzenie czy email nie jest pusty
      if (emailController.text.isEmpty) {
        _emailError = AppLocalizations.of(
          context,
        ).translate("register_email_missing");
      }
      // Sprawdzenie poprawności formatu email za pomocą wyrażenia regularnego
      else if (!RegExp(
        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
      ).hasMatch(emailController.text)) {
        _emailError = AppLocalizations.of(
          context,
        ).translate("register_email_wrong_format");
      } else {
        _emailError = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context).translate("edit_edit_account")),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: (AppLocalizations.of(
                  context,
                ).translate("edit_email")),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: (AppLocalizations.of(
                  context,
                ).translate("register_first_name")),
              ),
            ),
            TextField(
              controller: surnameController,
              decoration: InputDecoration(
                labelText: (AppLocalizations.of(
                  context,
                ).translate("register_last_name")),
              ),
            ),
            TextField(
              controller: streetController,
              decoration: InputDecoration(
                labelText: (AppLocalizations.of(
                  context,
                ).translate("register_street")),
              ),
            ),
            TextField(
              controller: buildingController,
              decoration: InputDecoration(
                labelText: (AppLocalizations.of(
                  context,
                ).translate("register_building_no")),
              ),
            ),
            TextField(
              controller: cityController,
              decoration: InputDecoration(
                labelText: (AppLocalizations.of(
                  context,
                ).translate("register_city")),
              ),
            ),
            TextField(
              controller: postalCodeController,
              decoration: InputDecoration(
                labelText: (AppLocalizations.of(
                  context,
                ).translate("register_postal_code")),
              ),
            ),
            TextField(
              controller: countryController,
              decoration: InputDecoration(
                labelText: (AppLocalizations.of(
                  context,
                ).translate("register_country")),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context).translate("edit_cancel")),
        ),
        FilledButton(
          onPressed: () async {
            validateEmail();
            if (_emailError == null) {
              _saveUserData();
            }
            else{
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(_emailError!)),
        );
            }
          },
          child: Text(AppLocalizations.of(context).translate("edit_save")),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/main.dart';
import 'package:mobile/tools/navigators.dart';
import 'package:mobile/tools/token_handler.dart';
import 'dart:convert';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  // Kontrolery do pól formularza
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _streetController = TextEditingController();
  final _buildingController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _countryController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _surnameController.dispose();
    _streetController.dispose();
    _buildingController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        // Sprawdzenie czy hasła są zgodne
        if (_passwordController.text != _confirmPasswordController.text) {
          setState(() {
            _errorMessage = AppLocalizations.of(
              context,
            ).translate("register_password_confirmation_failed");
            _isLoading = false;
          });
          return;
        }

        // Przygotowanie danych rejestracji
        final registerData = {
          'username': _usernameController.text,
          'email': _emailController.text,
          'password': _passwordController.text,
          'name': _nameController.text,
          'surname': _surnameController.text,
          'street': _streetController.text,
          'building': _buildingController.text,
          'city': _cityController.text,
          'postal_code': _postalCodeController.text,
          'country': _countryController.text,
        };

        // Wysłanie żądania rejestracji
        final response = await http.post(
          Uri.parse('$baseURL/api/auth/register'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(registerData),
        );
        final responseData = jsonDecode(response.body);
        if (response.statusCode == 200) {
          // Sukces - przetwarzanie otrzymanego JWT
          
          final jwtToken = responseData['accessToken'];

          // Zapisanie tokenu JWT
          await TokenHandler.saveToken(jwtToken);

          // Przejście do głównego ekranu
          Navigators.navigateToHome(context);
        } else if (response.statusCode == 400) {
          String warningMessage = "";
          if (responseData["detail"].toString() == "common_password"){
            warningMessage = AppLocalizations.of(context).translate("register_common_password");
          }
          else{
              AppLocalizations.of(context,).translate("register_account_in_database");
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                warningMessage,
              ),
            ),
          );
        } else {
          // Błąd - wyświetlenie komunikatu
          final errorData = jsonDecode(response.body);
          setState(() {
            _errorMessage = errorData['detail'] ?? 'Błąd rejestracji';
          });
        }
      } 
      finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate("register_app_bar")),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),

                // Ikona rejestracji
                const Icon(
                  Icons.app_registration,
                  size: 80,
                  color: Colors.blue,
                ),

                const SizedBox(height: 20),

                // Sekcja: Dane konta
                Text(
                  AppLocalizations.of(context).translate("register_label"),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                // Pole nazwa użytkownika
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(
                      context,
                    ).translate("register_username"),
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(
                        context,
                      ).translate("register_username_missing");
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Pole email
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(
                      context,
                    ).translate("register_email"),
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(
                        context,
                      ).translate("register_email_missing");
                    }
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value)) {
                      return AppLocalizations.of(
                        context,
                      ).translate("register_email_wrong_format");
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Pole hasło
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(
                      context,
                    ).translate("register_password_confirm"),
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(
                        context,
                      ).translate("register_password_missing");
                    }
                    if (value.length < 12) {
                      return AppLocalizations.of(
                        context,
                      ).translate("register_ password_too_short");
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Pole potwierdzenie hasła
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(
                      context,
                    ).translate("register_password_confirm"),
                    prefixIcon: Icon(Icons.lock_outline),
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(
                        context,
                      ).translate("register_password_confirmation_missing");
                    }
                    if (value != _passwordController.text) {
                      return AppLocalizations.of(
                        context,
                      ).translate("register_password_confirmation_failed");
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Sekcja: Dane osobowe (opcjonalne)
                Text(
                  AppLocalizations.of(
                    context,
                  ).translate("register_personal_data"),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                // Pole imię
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(
                      context,
                    ).translate("register_first_name"),
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                // Pole nazwisko
                TextFormField(
                  controller: _surnameController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(
                      context,
                    ).translate("register_last_name"),
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                // Pole ulica
                TextFormField(
                  controller: _streetController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(
                      context,
                    ).translate("register_street"),
                    prefixIcon: Icon(Icons.location_on_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                // Pole nr budynku
                TextFormField(
                  controller: _buildingController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(
                      context,
                    ).translate("register_building_no"),
                    prefixIcon: Icon(Icons.home_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                // Pole miasto
                TextFormField(
                  controller: _cityController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(
                      context,
                    ).translate("register_city"),
                    prefixIcon: Icon(Icons.location_city_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                // Pole kod pocztowy
                TextFormField(
                  controller: _postalCodeController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(
                      context,
                    ).translate("register_postal_code"),
                    prefixIcon: Icon(Icons.markunread_mailbox_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                // Pole kraj
                TextFormField(
                  controller: _countryController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(
                      context,
                    ).translate("register_country"),
                    prefixIcon: Icon(Icons.public),
                    border: OutlineInputBorder(),
                  ),
                ),

                // Komunikat błędu
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                const SizedBox(height: 32),
                FilledButton(
                  onPressed: _isLoading ? null : _register,
                  child:
                      _isLoading
                          ? const CircularProgressIndicator()
                          : Text(
                            AppLocalizations.of(
                              context,
                            ).translate("register_link"),
                            style: TextStyle(fontSize: 16),
                          ),
                ),

                const SizedBox(height: 16),

                // Powrót do logowania
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    AppLocalizations.of(
                      context,
                    ).translate("register_account_exist"),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

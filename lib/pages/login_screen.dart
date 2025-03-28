import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/main.dart';
import 'package:mobile/tools/navigators.dart';
import 'package:mobile/tools/token_handler.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'openid', 'profile'],
  );
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Logowanie standardowe
  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        // Przygotowanie danych logowania
        final credentials = {
          'login': _loginController.text,
          'password': _passwordController.text,
        };

        // Wysłanie żądania logowania
        final response = await http.post(
          Uri.parse('$baseURL/api/auth/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(credentials),
        );

        if (response.statusCode == 200) {
          // Sukces - przetwarzanie otrzymanego JWT
          final responseData = jsonDecode(response.body);
          final jwtToken = responseData['accessToken'];

          // Zapisanie tokenu JWT
          await TokenHandler.saveToken(jwtToken);

          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('google_user', false);

          // Przejście do głównego ekranu
          Navigators.navigateToHome(context);
        } else {
          // Błąd - wyświetlenie komunikatu
          final errorData = jsonDecode(response.body);
          setState(() {
            _errorMessage = errorData['detail'] ?? 'Błąd logowania';
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Błąd połączenia: $e';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _googleAuth() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // Użytkownik anulował logowanie Google
        setState(() {
          _isLoading = false;
        });
        return;
      }
      String userEmail = googleUser.email;
      String userId = googleUser.id;

      final registerData = {
        'username': userEmail,
        'email': userEmail,
        'password': userId + userEmail,
      };

      var response = await http.post(
        Uri.parse('$baseURL/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(registerData),
      );

      if (response.statusCode != 200) {
        response = await http.post(
          Uri.parse('$baseURL/api/auth/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'login': registerData['email'],
            'password': registerData['password'],
          }),
        );

        if (response.statusCode != 200) {
          _errorMessage = AppLocalizations.of(
            context,
          ).translate("google_local_account_exists");
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }

      final responseData = jsonDecode(response.body);
      final jwtToken = responseData['accessToken'];
      await TokenHandler.saveToken(jwtToken);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('google_user', true);

      Navigators.navigateToHome(context);
    } catch (e) {
      setState(() {
        _errorMessage = 'Błąd logowania przez Google: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate("login_app_bar")),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),

                // Logo aplikacji
                const Icon(Icons.lock_outline, size: 80, color: Colors.blue),

                const SizedBox(height: 40),

                // Pole email/login
                TextFormField(
                  controller: _loginController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(
                      context,
                    ).translate("login_email_login"),
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(
                        context,
                      ).translate("login_no_login");
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Pole hasło
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(
                      context,
                    ).translate("login_password"),
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(
                        context,
                      ).translate("login_no_password");
                    }
                    return null;
                  },
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

                const SizedBox(height: 24),

                FilledButton(
                  onPressed: _isLoading ? null : _login,
                  child:
                      _isLoading
                          ? const CircularProgressIndicator()
                          : Text(
                            AppLocalizations.of(
                              context,
                            ).translate("login_button"),
                            style: TextStyle(fontSize: 16),
                          ),
                ),

                const SizedBox(height: 16),

                // Separator
                Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(AppLocalizations.of(context).translate("or")),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),

                const SizedBox(height: 16),

                // Przycisk logowania przez Google
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : _googleAuth,
                  icon: Image.asset(
                    'assets/icons/google_logo.png.png',
                    height: 24,
                  ),
                  label: Text(
                    AppLocalizations.of(context).translate("login_with_google"),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Link do rejestracji
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(AppLocalizations.of(context).translate("no_account")),
                    TextButton(
                      onPressed: () {
                        Navigators.navigateToRegister(context);
                      },
                      child: Text(
                        AppLocalizations.of(context).translate("register_link"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

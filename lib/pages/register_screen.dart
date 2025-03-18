import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_page.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

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
            _errorMessage = 'Hasła nie są zgodne';
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
          Uri.parse('https://twoja-domena.pl/api/register'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(registerData),
        );

        if (response.statusCode == 200) {
          // Sukces - przetwarzanie otrzymanego JWT
          final responseData = jsonDecode(response.body);
          final jwtToken = responseData['token'];
          
          // Zapisanie tokenu JWT
          await _saveToken(jwtToken);
          
          // Przejście do głównego ekranu
          _navigateToHome();
        } else {
          // Błąd - wyświetlenie komunikatu
          final errorData = jsonDecode(response.body);
          setState(() {
            _errorMessage = errorData['detail'] ?? 'Błąd rejestracji';
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

  // Zapisywanie tokenu JWT
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
  }

  // Nawigacja do ekranu głównego
  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rejestracja'),
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
                const Text(
                  'Dane konta',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                
                // Pole nazwa użytkownika
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Nazwa użytkownika *',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Proszę wprowadzić nazwę użytkownika';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Pole email
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email *',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Proszę wprowadzić email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      return 'Proszę wprowadzić prawidłowy email';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Pole hasło
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Hasło *',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Proszę wprowadzić hasło';
                    }
                    if (value.length < 6) {
                      return 'Hasło musi mieć co najmniej 6 znaków';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Pole potwierdzenie hasła
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Potwierdź hasło *',
                    prefixIcon: Icon(Icons.lock_outline),
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Proszę potwierdzić hasło';
                    }
                    if (value != _passwordController.text) {
                      return 'Hasła nie są zgodne';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 24),
                
                // Sekcja: Dane osobowe (opcjonalne)
                const Text(
                  'Dane osobowe (opcjonalnie)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                
                // Pole imię
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Imię',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Pole nazwisko
                TextFormField(
                  controller: _surnameController,
                  decoration: const InputDecoration(
                    labelText: 'Nazwisko',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Sekcja: Adres (opcjonalny)
                const Text(
                  'Adres (opcjonalnie)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                
                // Pole ulica
                TextFormField(
                  controller: _streetController,
                  decoration: const InputDecoration(
                    labelText: 'Ulica',
                    prefixIcon: Icon(Icons.location_on_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Pole nr budynku
                TextFormField(
                  controller: _buildingController,
                  decoration: const InputDecoration(
                    labelText: 'Nr budynku/mieszkania',
                    prefixIcon: Icon(Icons.home_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Pole miasto
                TextFormField(
                  controller: _cityController,
                  decoration: const InputDecoration(
                    labelText: 'Miasto',
                    prefixIcon: Icon(Icons.location_city_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Pole kod pocztowy
                TextFormField(
                  controller: _postalCodeController,
                  decoration: const InputDecoration(
                    labelText: 'Kod pocztowy',
                    prefixIcon: Icon(Icons.markunread_mailbox_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Pole kraj
                TextFormField(
                  controller: _countryController,
                  decoration: const InputDecoration(
                    labelText: 'Kraj',
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
                
                // Przycisk rejestracji
                ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text(
                          'Zarejestruj się',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
                
                const SizedBox(height: 16),
                
                // Powrót do logowania
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Masz już konto? Zaloguj się'),
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
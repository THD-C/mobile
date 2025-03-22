import 'package:flutter/material.dart';
import 'package:mobile/dialogs/edit_profile_dialog.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/main.dart';
import 'package:mobile/pages/login_screen.dart';
import 'package:mobile/tools/token_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class AccountView extends StatelessWidget {
  const AccountView({super.key});

  @override
  Widget build(BuildContext context) {
    // Tu nie pobieramy już danych użytkownika - to zadanie zostało przeniesione do dialogu

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Pasek górny "Profil"
            const Padding(
              padding: EdgeInsets.only(top: 25.0, bottom: 16.0),
              child: Center(
                child: Text(
                  'Profil',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            
            
            
            const SizedBox(height: 24),
            
            ElevatedButton.icon(
              onPressed: () => _openEditProfileDialog(context),
              icon: const Icon(Icons.edit),
              label: const Text('Edytuj dane konta'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Przycisk "Wyloguj"
            FilledButton.icon(
              onPressed: () {
                TokenHandler.saveToken("");
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                  (Route<dynamic> route) => false);
              },
              icon: const Icon(Icons.logout),
              label: const Text('Wyloguj', style: TextStyle(fontSize: 16)),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: Colors.red,
              ),
            ),
            
            // Elastyczny odstęp, aby link do polityki był na dole
            const SizedBox(height: 40),
            
            // Link do polityki prywatności
            Center(
              child: TextButton(
                onPressed: () {
                  // Tutaj możesz dodać nawigację do strony z polityką prywatności
                },
                child: Text(
                  'Polityka Prywatności',
                  style: TextStyle(color: Colors.blue[700]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Metody otwierające dialogi
  void _openEditProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const EditProfileDialog(),
    ).then((success) {
      if (success == true) {
        // Pokazujemy informację o powodzeniu operacji
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dane zostały zaktualizowane')),
        );
      }
    });
  }
}
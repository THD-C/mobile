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

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Pasek górny "Profil"
            Padding(
              padding: EdgeInsets.only(top: 25.0, bottom: 16.0),
              child: Center(
                child: Text(
                  AppLocalizations.of(context).translate("account_profile_bar"),
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            
            
            
            const SizedBox(height: 24),
            
            ElevatedButton.icon(
              onPressed: () => _openEditProfileDialog(context),
              icon: const Icon(Icons.edit),
              label: Text(AppLocalizations.of(context).translate("account_edit_data")),
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
              label: Text(AppLocalizations.of(context).translate("account_logout"), style: TextStyle(fontSize: 16)),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: Colors.red,
              ),
            ),
            
            const SizedBox(height: 40),
            
            Center(
              child: TextButton(
                onPressed: () {
                  launchUrl(Uri.parse('$baseURL/${AppLocalizations.of(context,).translate("register_terms_link")}'));
                },
                child: Text(
                  AppLocalizations.of(context).translate("account_terms"),
                  style: TextStyle(color: Colors.blue[700]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  

  void _openEditProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const EditProfileDialog(),
    ).then((success) {
      if (success == true) {
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).translate("account_data_updated_successfully"))),
        );
      }
    });
  }
}
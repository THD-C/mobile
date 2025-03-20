import 'package:flutter/material.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/main.dart';
import 'package:mobile/tools/navigators.dart';
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
            Padding(
              padding: EdgeInsets.only(top: 20.0, bottom: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  AppLocalizations.of(context).translate("account_profile_bar"),
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                
              ),
            ),
            
            const SizedBox(height: 12),
            
            FilledButton.icon(
              onPressed: () {
                TokenHandler.saveToken("");
                Navigators.navigateToLogin(context);
              },
              icon: const Icon(Icons.logout),
              label: Text(AppLocalizations.of(context).translate("account_logout"), style: TextStyle(fontSize: 16)),
              
            ),
            
            
            const SizedBox(height: 20),
            
            Center(
              child: TextButton(
                onPressed: () {
                  launchUrl(Uri.parse('$baseURL/${AppLocalizations.of(context).translate("register_terms_link")}'));
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
}
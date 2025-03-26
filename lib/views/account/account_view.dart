import 'package:flutter/material.dart';
import 'package:mobile/dialogs/change_password_dialog.dart';
import 'package:mobile/dialogs/donate_dialog.dart';
//import 'package:mobile/dialogs/change_password_dialog.dart';
import 'package:mobile/dialogs/edit_profile_dialog.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/main.dart';
import 'package:mobile/tools/token_handler.dart';
import 'package:mobile/views/account/account_wallets_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class AccountView extends StatefulWidget {
  const AccountView({super.key});

  @override
  State<StatefulWidget> createState() => AccountViewState();
}

class AccountViewState extends State<AccountView> {
  bool? _googleUser;

  @override
  void initState() {
    super.initState();
    _loadGoogleUserStatus();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadGoogleUserStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _googleUser = prefs.getBool('google_user') ?? false;
    });
  }

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

            OutlinedButton.icon(
              onPressed: () => _openEditProfileDialog(context),
              icon: const Icon(Icons.edit),
              label: Text(
                AppLocalizations.of(context).translate("account_edit_data"),
                style: TextStyle(fontSize: 15),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20),
              ),
            ),

            const SizedBox(height: 24),

            _googleUser == true
                ? Container()
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _openChangePasswordDialog(context),
                      icon: const Icon(Icons.password),
                      label: Text(
                        AppLocalizations.of(
                          context,
                        ).translate("account_edit_password"),
                        style: TextStyle(fontSize: 15),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),

            OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AccountWalletsView()),
                );
              },
              icon: const Icon(Icons.wallet),
              label: Text(
                AppLocalizations.of(context).translate("wallets_show"),
                style: TextStyle(fontSize: 15),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20),
              ),
            ),

            const SizedBox(height: 24),

            OutlinedButton.icon(
              onPressed: () => _openDonateDialog(context),
              icon: const Icon(Icons.favorite),
              label: Text(
                AppLocalizations.of(context).translate("account_donate"),
                style: TextStyle(fontSize: 15),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20),
              ),
            ),

            const SizedBox(height: 200),

            FilledButton.icon(
              onPressed: () => TokenHandler.logout(context),
              icon: const Icon(Icons.logout),
              label: Text(
                AppLocalizations.of(context).translate("account_logout"),
                style: TextStyle(fontSize: 16),
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                foregroundColor: Colors.black,
                backgroundColor: Colors.red[900],
              ),
            ),

            const SizedBox(height: 40),

            Center(
              child: TextButton(
                onPressed: () {
                  launchUrl(
                    Uri.parse(
                      '$baseURL/${AppLocalizations.of(context).translate("register_terms_link")}',
                    ),
                  );
                },
                child: Text(
                  AppLocalizations.of(context).translate("account_terms"),
                  style: TextStyle(color: Colors.blue[300]),
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
          SnackBar(
            content: Text(
              AppLocalizations.of(
                context,
              ).translate("account_data_updated_successfully"),
            ),
          ),
        );
      }
    });
  }

  void _openChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ChangePasswordDialog(),
    ).then((success) {
      if (success == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(
                context,
              ).translate("account_data_updated_successfully"),
            ),
          ),
        );

        TokenHandler.logout(context);
      } else {
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
    });
  }

  void _openDonateDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => const DonateDialog());
  }
}

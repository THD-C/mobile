import 'package:flutter/material.dart';
import 'package:mobile/l10n/app_localizations.dart';

class AddWalletDialog extends StatelessWidget {
  const AddWalletDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context).translate('wallets_add_wallet')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: AppLocalizations.of(
                context,
              ).translate('wallets_currency'),
            ),
          ),
          TextField(
            decoration: InputDecoration(
              labelText: AppLocalizations.of(
                context,
              ).translate('wallets_initial_value'),
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: Text(AppLocalizations.of(context).translate('wallets_cancel')),
        ),
        ElevatedButton(
          onPressed: () {
            // Add wallet creation logic here
            Navigator.of(context).pop(); // Close the dialog
            print("New wallet added!");
          },
          child: Text(AppLocalizations.of(context).translate('wallets_save')),
        ),
      ],
    );
  }
}

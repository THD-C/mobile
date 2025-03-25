import 'package:flutter/material.dart';
import 'package:mobile/dialogs/add_wallet_dialog.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/models/wallet.dart';
import 'package:mobile/tools/api_servicer/api_wallet.dart';
import 'package:mobile/tools/repository/wallet_repository.dart';

class AccountWalletsView extends StatefulWidget {
  const AccountWalletsView({Key? key}) : super(key: key);

  @override
  _AccountWalletsViewState createState() => _AccountWalletsViewState();
}

class _AccountWalletsViewState extends State<AccountWalletsView> {
  void _addWallet(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AddWalletDialog(),
    );
  }

  void _addMoneyToFiat(Wallet wallet) {
    if (!wallet.isCrypto) {
      print("Adding money to ${wallet.currency} wallet!");
    } else {
      print("Cannot add money to crypto wallet");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).translate('wallets_view_title'),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => _addWallet(context),
            child: Text(
              AppLocalizations.of(context).translate('wallets_add_wallet'),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Wallet>>(
        future: WalletRepository.fetchAll(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            final wallets = snapshot.data!;
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: wallets.length,
                    itemBuilder: (context, index) {
                      final wallet = wallets[index];
                      return ListTile(
                        title: Text("${wallet.currency}"),
                        subtitle: Text("Balance: ${wallet.value}"),
                        trailing: IconButton(
                          icon: Icon(Icons.add, color: Colors.green[500]),
                          onPressed: () => _addMoneyToFiat(wallet),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          } else {
            return Center(
              child: Text(
                AppLocalizations.of(
                  context,
                ).translate('wallets_no_wallets_found'),
              ),
            );
          }
        },
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/dialogs/add_wallet_dialog.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/models/wallet.dart';
import 'package:mobile/tools/repositories/wallet_repository.dart';

class AccountWalletsView extends StatefulWidget {
  const AccountWalletsView({Key? key}) : super(key: key);

  @override
  _AccountWalletsViewState createState() => _AccountWalletsViewState();
}

class _AccountWalletsViewState extends State<AccountWalletsView> {
  final StreamController<List<Wallet>> _walletStreamController =
      StreamController();

  @override
  void initState() {
    super.initState();
    _fetchWallets();
  }

  Future<List<Wallet>> _fetchWallets() async {
    try {
      final wallets = await WalletRepository.fetchAll();
      _walletStreamController.add(wallets);

      return wallets;
    } catch (e) {
      _walletStreamController.addError(e);
      return [];
    }
  }

  void _addWallet(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AddWalletDialog(),
    ).then(
      (wallet) => {
        if (wallet != null) {_fetchWallets()},
      },
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
      body: StreamBuilder<List<Wallet>>(
        stream: _walletStreamController.stream,
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
                        title: Text('${wallet.currency}'),
                        subtitle: Text(
                          '${AppLocalizations.of(context).translate('wallets_balance')}: ${wallet.value}',
                        ),
                        trailing:
                            wallet.isCrypto == false
                                ? IconButton(
                                  icon: Icon(Icons.add, color: Colors.green),
                                  onPressed: () => _addMoneyToFiat(wallet),
                                )
                                : null,
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

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile/dialogs/delete_confirmation_dialog.dart';
import 'package:mobile/dialogs/wallet/add_wallet_dialog.dart';
import 'package:mobile/dialogs/wallet/add_wallet_money_dialog.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/models/wallet.dart';
import 'package:mobile/tools/repositories/wallet_repository.dart';
import 'package:mobile/views/transaction_history_view.dart';

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
    ).then((wallet) {
      if (wallet != null) {
        _fetchWallets();
      }
    });
  }

  void _addMoneyToFiat(Wallet wallet) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AddWalletMoneyDialog(wallet: wallet),
    ).then((value) {
      if (value) {
        _fetchWallets();
      }
    });
  }

  void _showDeleteDialog(Wallet wallet) {
    showDialog(
      context: context,
      builder:
          (BuildContext context) =>
              DeleteConfirmationDialog(itemName: wallet.currency),
    ).then((value) {
      if (value) {
        WalletRepository.delete(wallet.id).then((_) => _fetchWallets());
      }
    });
  }

  void _openTransactionHistory(Wallet wallet) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionHistoryPage(wallet: wallet),
      ),
    );
  }

  @override
  void dispose() {
    _walletStreamController.close();
    super.dispose();
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
                          '${AppLocalizations.of(context).translate('wallets_balance')}: ${wallet.isCrypto ? wallet.value : wallet.value.toStringAsFixed(2)}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.history, color: Colors.blue),
                              onPressed: () => _openTransactionHistory(wallet),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _showDeleteDialog(wallet),
                            ),
                            wallet.isCrypto == false
                                ? IconButton(
                                  icon: Icon(Icons.add, color: Colors.green),
                                  onPressed: () => _addMoneyToFiat(wallet),
                                )
                                : SizedBox(width: 0),
                          ],
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

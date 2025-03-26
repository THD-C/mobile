import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/models/currency.dart';
import 'package:mobile/models/wallet.dart';
import 'package:mobile/tools/repositories/currency_repository.dart';
import 'package:mobile/tools/repositories/wallet_repository.dart';
import 'package:mobile/widgets/currency/currency_selector.dart';

class AddWalletDialog extends StatefulWidget {
  const AddWalletDialog({super.key});

  @override
  State<AddWalletDialog> createState() => _AddWalletDialogState();
}

class _AddWalletDialogState extends State<AddWalletDialog> {
  late final TextEditingController currencyController = TextEditingController();

  Currency? _selectedCurrency;
  late final List<Currency> availableCurrencies;

  @override
  void initState() {
    super.initState();
    _fetchCurrencies();
  }

  @override
  void dispose() {
    currencyController.dispose();
    super.dispose();
  }

  Future<void> _fetchCurrencies() async {
    try {
      final CurrencyList currencyList = await CurrencyRepository.fetchAll();

      setState(() {
        availableCurrencies = currencyList.currencies;
      });
    } catch (e) {
      Logger().e(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(
              context,
            ).translate("wallets_currencies_loading_error"),
          ),
        ),
      );
    }
  }

  Future<void> _add() async {
    try {
      final newWallet = {'currency': _selectedCurrency!.name};

      final Wallet wallet = await WalletRepository.create(newWallet);

      if (mounted) {
        Navigator.pop(context, wallet);
      }
    } catch (e) {
      Logger().e(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(
              context,
            ).translate("wallets_add_dialog_wallet_error"),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        AppLocalizations.of(
          context,
        ).translate("wallets_add_wallet_dialog_title"),
      ),
      content: SingleChildScrollView(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CurrencySelector(
              selectedCurrency: _selectedCurrency,
              currencies: availableCurrencies,
              onCurrencySelected: _onCurrencySelected,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context).translate("wallet_cancel")),
        ),
        FilledButton(
          onPressed: () async {
            await _add();
          },
          child: Text(AppLocalizations.of(context).translate("wallet_save")),
        ),
      ],
    );
  }

  void _onCurrencySelected(Currency currency) {
    setState(() {
      _selectedCurrency = currency;
      currencyController.value = TextEditingValue(
        text: currency.name.toUpperCase(),
      );
    });
  }
}

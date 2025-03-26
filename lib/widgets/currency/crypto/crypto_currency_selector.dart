import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/models/currency.dart';
import 'package:mobile/tools/repositories/currency_repository.dart';
import 'package:mobile/widgets/currency/currency_selector.dart';

class CryptoCurrencySelector extends StatefulWidget {
  final Currency? selectedCurrency;
  final Function(Currency) onCurrencySelected;

  const CryptoCurrencySelector({
    super.key,
    required this.selectedCurrency,
    required this.onCurrencySelected,
  });

  @override
  _CryptoCurrencySelectorState createState() => _CryptoCurrencySelectorState();
}

class _CryptoCurrencySelectorState extends State<CryptoCurrencySelector> {
  late List<Currency> _cryptos = [];

  @override
  void initState() {
    super.initState();
    _fetchCurrencies();
  }

  Future<void> _fetchCurrencies() async {
    try {
      final CurrencyList cryptoList = await CurrencyRepository.fetchAllCrypto();
      setState(() {
        _cryptos = cryptoList.currencies;
      });
    } catch (error) {
      Logger().e(error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(
              context,
            ).translate("crypto_currencies_loading_error"),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CurrencySelector(
      selectedCurrency: widget.selectedCurrency,
      currencies: _cryptos,
      onCurrencySelected: widget.onCurrencySelected,
    );
  }
}

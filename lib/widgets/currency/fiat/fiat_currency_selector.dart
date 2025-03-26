import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/models/currency.dart';
import 'package:mobile/tools/repositories/currency_repository.dart';
import 'package:mobile/widgets/currency/currency_selector.dart';

class FiatCurrencySelector extends StatefulWidget {
  final Currency? selectedCurrency;
  final Function(Currency) onCurrencySelected;

  const FiatCurrencySelector({
    super.key,
    required this.selectedCurrency,
    required this.onCurrencySelected,
  });

  @override
  _FiatCurrencySelectorState createState() => _FiatCurrencySelectorState();
}

class _FiatCurrencySelectorState extends State<FiatCurrencySelector> {
  late List<Currency> _fiats = [];

  @override
  void initState() {
    super.initState();
    _fetchCurrencies();
  }

  Future<void> _fetchCurrencies() async {
    try {
      final CurrencyList fiatList = await CurrencyRepository.fetchAllFiat();
      setState(() {
        _fiats = fiatList.currencies;
      });
    } catch (error) {
      Logger().e(error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(
              context,
            ).translate("crypto_fiats_loading_error"),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CurrencySelector(
      selectedCurrency: widget.selectedCurrency,
      currencies: _fiats,
      onCurrencySelected: widget.onCurrencySelected,
    );
  }
}

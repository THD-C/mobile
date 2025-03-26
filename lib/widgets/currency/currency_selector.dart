import 'package:flutter/material.dart';
import 'package:mobile/config/app_config.dart';
import 'package:mobile/models/currency.dart';
import 'package:mobile/widgets/currency/currency_selection_dialog.dart';

class CurrencySelector extends StatelessWidget {
  final Currency? selectedCurrency;
  final List<Currency> currencies;
  final Function(Currency) onCurrencySelected;

  const CurrencySelector({
    super.key,
    required this.selectedCurrency,
    required this.currencies,
    required this.onCurrencySelected,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasCurrencies = currencies.isNotEmpty;

    return GestureDetector(
      onTap: hasCurrencies ? () => _showSelectionDialog(context) : null,
      child: Row(
        children: [
          Text(
            selectedCurrency?.name.toUpperCase() ??
                AppConfig().defaultCurrency.name,
            style: TextStyle(
              fontWeight: FontWeight.normal,
              // color: hasCurrencies ? null : Colors.grey,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.arrow_drop_down_sharp,
            // color: hasCurrencies ? null : Colors.grey,
          ),
        ],
      ),
    );
  }

  void _showSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => CurrencySelectionDialog(
            selectedCurrency: selectedCurrency,
            currencies: currencies,
            onCurrencySelected: onCurrencySelected,
          ),
    );
  }
}

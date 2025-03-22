import 'package:flutter/material.dart';
import 'package:mobile/models/fiat_currency.dart';
import 'package:mobile/widgets/currency/currency_selection_dialog.dart';

class CurrencySelector extends StatelessWidget {
  final FiatCurrency? selectedCurrency;
  final List<FiatCurrency> currencies;
  final Function(FiatCurrency) onCurrencySelected;

  const CurrencySelector({
    super.key,
    required this.selectedCurrency,
    required this.currencies,
    required this.onCurrencySelected,
  });

  @override
  Widget build(BuildContext context) {
    if (currencies.isEmpty) return Container();

    return GestureDetector(
      onTap: () => _showSelectionDialog(context),
      child: Row(
        children: [
          Text(
            selectedCurrency?.name.toUpperCase() ?? 'USD',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 4),
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

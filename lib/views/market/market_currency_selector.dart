import 'package:flutter/material.dart';
import 'package:mobile/models/currency.dart';

import 'market_selector_container.dart';

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
    final String currentValue = selectedCurrency?.name ??
        (currencies.isNotEmpty ? currencies.first.name : '');

    return SelectorContainer(
      child: DropdownButton<String>(
        value: currentValue,
        underline: Container(),
        icon: const Icon(Icons.keyboard_arrow_down, size: 20),
        borderRadius: BorderRadius.circular(8),
        items: currencies.map<DropdownMenuItem<String>>((Currency currency) {
          return DropdownMenuItem<String>(
            value: currency.name,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 8),
                Text(
                  currency.name.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: (String? currencyName) {
          if (currencyName != null && currencies.isNotEmpty) {
            final selectedCurr = currencies.firstWhere(
                  (c) => c.name == currencyName,
              orElse: () => currencies.first,
            );
            onCurrencySelected(selectedCurr);
          }
        },
      ),
    );
  }
}
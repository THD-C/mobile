import 'package:flutter/material.dart';
import 'package:mobile/models/currency.dart';

class PortfolioCurrencySelector extends StatelessWidget {
  final Currency? selectedCurrency;
  final List<Currency> currencies;
  final Function(Currency) onCurrencySelected;

  const PortfolioCurrencySelector({
    super.key,
    required this.selectedCurrency,
    required this.currencies,
    required this.onCurrencySelected,
  });

  @override
  Widget build(BuildContext context) {
    if (currencies.isEmpty) {
      return const Text("No currencies available");
    }

    // Find currency by name to ensure proper matching
    final currentValue = selectedCurrency != null
        ? currencies.firstWhere(
            (c) => c.name == selectedCurrency!.name,
        orElse: () => currencies.first)
        : currencies.first;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: DropdownButton<String>(
        value: currentValue.name,
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
          if (currencyName != null) {
            final selectedCurr = currencies.firstWhere(
                    (c) => c.name == currencyName
            );
            onCurrencySelected(selectedCurr);
          }
        },
      ),
    );
  }
}
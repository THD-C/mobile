import 'package:flutter/material.dart';
import 'package:mobile/models/currency.dart';
import 'package:mobile/views/market/market_currency_selector.dart';
import 'package:mobile/views/market/market_view_type_selector.dart';

class MarketHeader extends StatelessWidget {
  final bool showPriceRange;
  final VoidCallback onToggleView;
  final Currency? selectedCurrency;
  final List<Currency> currencies;
  final Function(Currency) onCurrencySelected;

  const MarketHeader({
    super.key,
    required this.showPriceRange,
    required this.onToggleView,
    required this.selectedCurrency,
    required this.currencies,
    required this.onCurrencySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.fromLTRB(16.0, 50.0, 16.0, 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ViewTypeSelector(
              showPriceRange: showPriceRange,
              onToggleView: onToggleView,
            ),
            CurrencySelector(
              selectedCurrency: selectedCurrency,
              currencies: currencies,
              onCurrencySelected: onCurrencySelected,
            ),
          ],
        ),
      ),
    );
  }
}
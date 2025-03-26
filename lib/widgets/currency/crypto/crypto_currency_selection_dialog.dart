import 'package:flutter/material.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/models/currency.dart';

class FiatCurrencySelectionDialog extends StatelessWidget {
  final Currency? selectedCurrency;
  final List<Currency> currencies;
  final Function(Currency) onCurrencySelected;

  const FiatCurrencySelectionDialog({
    super.key,
    required this.selectedCurrency,
    required this.currencies,
    required this.onCurrencySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.5,
          maxWidth: MediaQuery.of(context).size.width * 0.3,
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text(
                AppLocalizations.of(
                  context,
                ).translate("currency_selector_title"),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(height: 1),
            Flexible(child: _buildCurrencyList(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyList(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: currencies.length,
      itemBuilder: (context, index) {
        final currency = currencies[index];
        final isSelected = currency.name == selectedCurrency?.name;

        return ListTile(
          title: Text(
            currency.name.toUpperCase(),
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          trailing: isSelected ? Icon(Icons.check) : null,
          onTap: () {
            Navigator.pop(context);
            onCurrencySelected(currency);
          },
        );
      },
    );
  }
}

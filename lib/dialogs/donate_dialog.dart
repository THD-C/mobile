import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/models/crypto_currency.dart';
import 'package:mobile/models/fiat_currency.dart';
import 'package:mobile/tools/api_servicer/api_payment.dart';
import 'package:mobile/tools/repository/market_repository.dart';
import 'package:mobile/widgets/currency/currency_selector.dart';
import 'package:url_launcher/url_launcher.dart';

class DonateDialog extends StatefulWidget {
  const DonateDialog({super.key});

  @override
  State<DonateDialog> createState() => _DonateDialogState();
}

class _DonateDialogState extends State<DonateDialog> {
  late final TextEditingController currencyController = TextEditingController(
    text: 'USD',
  );
  late final TextEditingController nominalController = TextEditingController(
    text: '1',
  );

  FiatCurrency? _selectedFiatCurrency;
  final List<FiatCurrency> availableCurrencies = [
    FiatCurrency(name: 'USD'),
    FiatCurrency(name: 'EUR'),
    FiatCurrency(name: 'GBP'),
    FiatCurrency(name: 'PLN'),
  ];

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    _onCurrencySelected(FiatCurrency(name: 'USD'));

    super.initState();
  }

  @override
  void dispose() {
    currencyController.dispose();
    nominalController.dispose();
    super.dispose();
  }

  Future<void> _donate() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final donateDetails = {
        'currency': _selectedFiatCurrency!.name,
        'nominal': nominalController.text,
      };

      final String paymentLink = await PaymentApiService().donate(
        donateDetails,
      );

      final Uri paymentUri = Uri.parse(paymentLink);
      if (!await launchUrl(paymentUri)) {
        throw Exception('Could not launch $paymentUri');
      }

      // Zamknij dialog z sygnałem sukcesu
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        _errorMessage = AppLocalizations.of(
          context,
        ).translate("donate_dialog_donate_data_error");
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(
              context,
            ).translate("donate_dialog_donate_data_error"),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context).translate("donate_title")),
      content: SingleChildScrollView(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: TextField(
                keyboardType: TextInputType.number,
                controller: nominalController,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(
                      r'^[0-9]*\.?[0-9]*$',
                    ), // Allows only numbers and an optional decimal point
                  ),
                ],
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(
                    context,
                  ).translate("donate_nominal"),
                  errorText:
                      (double.tryParse(nominalController.text) ?? 0) < 0
                          ? AppLocalizations.of(
                            context,
                          ).translate("value_must_be_greater_than_zero")
                          : null,
                ),
                onChanged: (value) {
                  if ((double.tryParse(value) ?? 0) < 0) {
                    setState(() {
                      _errorMessage = AppLocalizations.of(
                        context,
                      ).translate('value_must_be_greater_than_zero');
                    });
                  }
                },
              ),
            ),
            SizedBox(width: 10),
            CurrencySelector(
              selectedCurrency: _selectedFiatCurrency,
              currencies: availableCurrencies,
              onCurrencySelected: _onCurrencySelected,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context).translate("donate_cancel")),
        ),
        FilledButton(
          onPressed: () async {
            await _donate();
          },
          child: Text(AppLocalizations.of(context).translate("donate_pay")),
        ),
      ],
    );
  }

  void _onCurrencySelected(FiatCurrency currency) {
    setState(() {
      _selectedFiatCurrency = currency;
      currencyController.value = TextEditingValue(
        text: currency.name.toUpperCase(),
      );
    });
  }
}

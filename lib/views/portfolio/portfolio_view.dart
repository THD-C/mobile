import 'package:flutter/material.dart';
import 'package:mobile/config/app_config.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/models/currency.dart';
import 'package:mobile/tools/repositories/currency_repository.dart';
import 'package:mobile/tools/repositories/portfolio_repository.dart';
import 'package:mobile/views/portfolio/portfolio_content.dart';
import 'package:mobile/views/portfolio/portfolio_currency_selector.dart';

class PortfolioView extends StatefulWidget {
  const PortfolioView({super.key});

  @override
  PortfolioViewState createState() => PortfolioViewState();
}

class PortfolioViewState extends State<PortfolioView> {
  PortfolioDiversityResponse _portfolioData = PortfolioDiversityResponse(
    calculationFiatCurrency: '',
    cryptoWalletsStatistics: [],
  );
  CurrencyList _fiatCurrencyList = CurrencyList.empty();
  bool _isLoading = false;
  String? _errorMessage;
  Currency? _selectedFiatCurrency;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load all available fiat currencies
      _fiatCurrencyList = await CurrencyRepository.fetchAllFiat();

      if (_fiatCurrencyList.currencies.isNotEmpty && _selectedFiatCurrency == null) {
        _selectedFiatCurrency = _fiatCurrencyList.currencies.first;
      }

      String fiatCurrency = _selectedFiatCurrency?.name ??
          AppConfig().defaultCurrency.name.toLowerCase();

      _portfolioData = await PortfolioRepository.fetchPortfolioDiversity(
        "1", // Use default wallet ID since we're not selecting wallets
        fiatCurrency,
      );
    } catch (e) {
      _errorMessage = AppLocalizations.of(context).translate('portfolio_error_loading') ??
          'Failed to load portfolio data';
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _onCurrencySelected(Currency currency) async {
    if (currency.name == _selectedFiatCurrency?.name) return;

    setState(() {
      _selectedFiatCurrency = currency;
      _isLoading = true;
    });

    try {
      _portfolioData = await PortfolioRepository.fetchPortfolioDiversity(
        "1", // Use default wallet ID
        currency.name,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Card(
            elevation: 2,
            margin: const EdgeInsets.fromLTRB(16.0, 50.0, 16.0, 8.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: PortfolioCurrencySelector(
                      selectedCurrency: _selectedFiatCurrency,
                      currencies: _fiatCurrencyList.currencies,
                      onCurrencySelected: _onCurrencySelected,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Use Expanded to ensure the content fits
          Expanded(
            child: PortfolioContent(
              isLoading: _isLoading,
              errorMessage: _errorMessage,
              portfolioData: _portfolioData,
              onRefresh: _loadData,
            ),
          ),
        ],
      ),
    );
  }
}
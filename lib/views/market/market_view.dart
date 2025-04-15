import 'package:flutter/material.dart';
import 'package:mobile/config/app_config.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/models/coin.dart';
import 'package:mobile/models/currency.dart';
import 'package:mobile/tools/repositories/market_repository.dart';

import 'market_content.dart';
import 'market_header.dart';

class MarketView extends StatefulWidget {
  const MarketView({super.key});

  @override
  MarketsViewState createState() => MarketsViewState();
}

class MarketsViewState extends State<MarketView> {
  CoinList _cryptoCurrencyList = CoinList.empty();
  CurrencyList _fiatCurrencyList = CurrencyList.empty();
  bool _isLoading = false;
  String? _errorMessage;
  bool _showPriceRange = false;
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
      _fiatCurrencyList = await MarketRepository.fetchUserFiatCurrencies();
      String defaultCurrency =
          _fiatCurrencyList.currencies.isNotEmpty
              ? _fiatCurrencyList.currencies.first.name
              : AppConfig().defaultCurrency.name.toLowerCase();

      _cryptoCurrencyList = await MarketRepository.fetchCryptoCurrencies(
        defaultCurrency,
      );

      if (_fiatCurrencyList.currencies.isNotEmpty &&
          _selectedFiatCurrency == null) {
        _selectedFiatCurrency = _fiatCurrencyList.currencies.first;
      }
    } catch (e) {
      _errorMessage = AppLocalizations.of(
        context,
      ).translate('market_error_loading');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _toggleViewMode() {
    setState(() => _showPriceRange = !_showPriceRange);
  }

  Future<void> _onCurrencySelected(Currency currency) async {
    if (currency.name == _selectedFiatCurrency?.name) return;

    setState(() {
      _selectedFiatCurrency = currency;
      _isLoading = true;
    });

    try {
      _cryptoCurrencyList = await MarketRepository.fetchCryptoCurrencies(
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
    return Column(
      children: [
        MarketHeader(
          showPriceRange: _showPriceRange,
          onToggleView: _toggleViewMode,
          selectedCurrency: _selectedFiatCurrency,
          currencies: _fiatCurrencyList.currencies,
          onCurrencySelected: _onCurrencySelected,
        ),
        Expanded(
          child: MarketContent(
            isLoading: _isLoading,
            errorMessage: _errorMessage,
            cryptocurrencies: _cryptoCurrencyList,
            onRefresh: _loadData,
            showPriceRange: _showPriceRange,
          ),
        ),
      ],
    );
  }
}

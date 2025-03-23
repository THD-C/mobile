import 'package:flutter/material.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/models/crypto_currency.dart';
import 'package:mobile/models/fiat_currency.dart';
import 'package:mobile/tools/repository/market_repository.dart';
import 'package:mobile/widgets/buttons/change_view_button.dart';
import 'package:mobile/widgets/crypto/crypto_list.dart';
import 'package:mobile/widgets/currency/currency_selector.dart';

class MarketsView extends StatefulWidget {
  const MarketsView({super.key});

  @override
  MarketsViewState createState() => MarketsViewState();
}

class MarketsViewState extends State<MarketsView> {
  CryptoCurrencyList _cryptoCurrencyList = CryptoCurrencyList.empty();
  FiatCurrencyList _fiatCurrencyList = FiatCurrencyList.empty();
  bool _isLoading = false;
  String? _errorMessage;
  bool _showPriceRange = false;
  FiatCurrency? _selectedFiatCurrency;

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
      _fiatCurrencyList = await CurrencyRepository.fetchUserFiatCurrencies();
      String defaultCurrency =
          _fiatCurrencyList.currencies.isNotEmpty
              ? _fiatCurrencyList.currencies.first.name
              : 'usd';

      _cryptoCurrencyList = await CurrencyRepository.fetchCryptoCurrencies(
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

  Future<void> _onCurrencySelected(FiatCurrency currency) async {
    if (currency.name == _selectedFiatCurrency?.name) return;

    setState(() {
      _selectedFiatCurrency = currency;
      _isLoading = true;
    });

    try {
      _cryptoCurrencyList = await CurrencyRepository.fetchCryptoCurrencies(
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

class MarketHeader extends StatelessWidget {
  final bool showPriceRange;
  final VoidCallback onToggleView;
  final FiatCurrency? selectedCurrency;
  final List<FiatCurrency> currencies;
  final Function(FiatCurrency) onCurrencySelected;

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
    return Padding(
      padding: const EdgeInsets.all(45.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ChangeViewButton(
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
    );
  }
}

class MarketContent extends StatelessWidget {
  final bool isLoading;
  final String? errorMessage;
  final CryptoCurrencyList cryptocurrencies;
  final Future<void> Function() onRefresh;
  final bool showPriceRange;

  const MarketContent({
    super.key,
    required this.isLoading,
    required this.errorMessage,
    required this.cryptocurrencies,
    required this.onRefresh,
    required this.showPriceRange,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (errorMessage != null) {
      return Center(child: Text(errorMessage!));
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: CryptoListView(
        cryptocurrencies: cryptocurrencies,
        onRefresh: onRefresh,
        showPriceRange: showPriceRange,
      ),
    );
  }
}

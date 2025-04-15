import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:mobile/config/app_config.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/models/currency.dart';
import 'package:mobile/models/crypto_statistic.dart';
import 'package:mobile/tools/repositories/market_repository.dart';
import 'package:mobile/tools/repositories/portfolio_repository.dart';
import 'package:mobile/widgets/currency/fiat/fiat_currency_selector.dart';

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
      _fiatCurrencyList = await MarketRepository.fetchUserFiatCurrencies();
      String defaultCurrency = _fiatCurrencyList.currencies.isNotEmpty
          ? _fiatCurrencyList.currencies.first.name
          : AppConfig().defaultCurrency.name.toLowerCase();

      if (_fiatCurrencyList.currencies.isNotEmpty && _selectedFiatCurrency == null) {
        _selectedFiatCurrency = _fiatCurrencyList.currencies.first;
      }

      _portfolioData = await PortfolioRepository.fetchPortfolioDiversity(
        "1", // In production, get the actual user ID
        _selectedFiatCurrency?.name ?? defaultCurrency,
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
        "1", // In production, get the actual user ID
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
        PortfolioHeader(
          selectedCurrency: _selectedFiatCurrency,
          currencies: _fiatCurrencyList.currencies,
          onCurrencySelected: _onCurrencySelected,
        ),
        Expanded(
          child: PortfolioContent(
            isLoading: _isLoading,
            errorMessage: _errorMessage,
            portfolioData: _portfolioData,
            onRefresh: _loadData,
          ),
        ),
      ],
    );
  }
}

class PortfolioHeader extends StatelessWidget {
  final Currency? selectedCurrency;
  final List<Currency> currencies;
  final Function(Currency) onCurrencySelected;

  const PortfolioHeader({
    super.key,
    required this.selectedCurrency,
    required this.currencies,
    required this.onCurrencySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            AppLocalizations.of(context).translate('portfolio') ?? 'Portfolio',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          FiatCurrencySelector(
            selectedCurrency: selectedCurrency,
            onCurrencySelected: onCurrencySelected,
          ),
        ],
      ),
    );
  }
}

class PortfolioContent extends StatelessWidget {
  final bool isLoading;
  final String? errorMessage;
  final PortfolioDiversityResponse portfolioData;
  final Future<void> Function() onRefresh;

  const PortfolioContent({
    super.key,
    required this.isLoading,
    required this.errorMessage,
    required this.portfolioData,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (errorMessage != null) {
      return Center(child: Text(errorMessage!));
    }
    if (portfolioData.cryptoWalletsStatistics.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context).translate('portfolio_empty') ??
              'No cryptocurrencies in your portfolio',
        ),
      );
    }

    final double totalValue = portfolioData.cryptoWalletsStatistics
        .fold(0.0, (sum, stat) => sum + stat.fiatValue);

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '${AppLocalizations.of(context).translate('total_value') ?? 'Total Value'}: '
                    '${totalValue.toStringAsFixed(2)} ${portfolioData.calculationFiatCurrency.toUpperCase()}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            SizedBox(
              height: 300,
              child: _buildPieChart(context),
            ),
            _buildPortfolioList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(BuildContext context) {
    return SfCircularChart(
      legend: Legend(
        isVisible: true,
        position: LegendPosition.bottom,
        overflowMode: LegendItemOverflowMode.wrap,
      ),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <CircularSeries>[
        PieSeries<CryptoStatistic, String>(
          dataSource: portfolioData.cryptoWalletsStatistics,
          xValueMapper: (CryptoStatistic data, _) => data.cryptocurrency,
          yValueMapper: (CryptoStatistic data, _) => data.shareInPortfolio,
          dataLabelMapper: (CryptoStatistic data, _) =>
          '${data.cryptocurrency}\n${data.shareInPortfolio.toStringAsFixed(1)}%',
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            labelPosition: ChartDataLabelPosition.outside,
          ),
          pointColorMapper: (CryptoStatistic data, _) =>
              _getCryptoColor(data.cryptocurrency),
        ),
      ],
    );
  }

  Widget _buildPortfolioList(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: portfolioData.cryptoWalletsStatistics.length,
      itemBuilder: (context, index) {
        final stat = portfolioData.cryptoWalletsStatistics[index];
        final cryptoAmount = stat.fiatValue / stat.currentPrice;

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: _getCryptoColor(stat.cryptocurrency),
            child: Text(
              stat.cryptocurrency[0],
              style: const TextStyle(color: Colors.white),
            ),
          ),
          title: Text(
            stat.cryptocurrency,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text('${cryptoAmount.toStringAsFixed(2)} ${stat.cryptocurrency}'),
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${stat.fiatValue.toStringAsFixed(2)} ${portfolioData.calculationFiatCurrency.toUpperCase()}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '${stat.shareInPortfolio.toStringAsFixed(2)}%',
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getCryptoColor(String cryptocurrency) {
    final Map<String, Color> colors = {
      'BITCOIN': Colors.orange,
      'ETHEREUM': Colors.blue,
      'RIPPLE': Colors.indigo,
      'XRP': Colors.indigo,
      'TETHER': Colors.green,
      'BNB': Colors.yellow.shade700,
      'DOGECOIN': Colors.amber,
      'SOLANA': Colors.purple,
      'CARDANO': Colors.blue.shade800,
      'LITECOIN': Colors.grey.shade800,
    };

    return colors[cryptocurrency] ??
        Colors.primaries[cryptocurrency.hashCode % Colors.primaries.length];
  }
}
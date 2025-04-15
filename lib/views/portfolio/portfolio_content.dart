import 'package:flutter/material.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/models/crypto_statistic.dart';
import 'package:mobile/tools/repositories/portfolio_repository.dart';
import 'package:mobile/views/portfolio/portfolio_chart.dart';
import 'package:mobile/views/portfolio/portfolio_item_card.dart';

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

    final double totalValue = portfolioData.cryptoWalletsStatistics.fold(
      0.0,
      (sum, stat) => sum + stat.fiatValue,
    );

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          PortfolioHeader(
            totalValue: totalValue,
            currencyCode: portfolioData.calculationFiatCurrency,
          ),
          SizedBox(
            height: 300,
            child: PortfolioChart(
              statistics: portfolioData.cryptoWalletsStatistics,
            ),
          ),
          const SizedBox(height: 8),
          PortfolioItemList(
            statistics: portfolioData.cryptoWalletsStatistics,
            currencyCode: portfolioData.calculationFiatCurrency,
          ),
        ],
      ),
    );
  }
}

class PortfolioHeader extends StatelessWidget {
  final double totalValue;
  final String currencyCode;

  const PortfolioHeader({
    super.key,
    required this.totalValue,
    required this.currencyCode,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        '${AppLocalizations.of(context).translate('portfolio_total_value') ?? 'Total Value'}: '
        '${totalValue.toStringAsFixed(2)} ${currencyCode.toUpperCase()}',
        style: Theme.of(context).textTheme.titleMedium,
        textAlign: TextAlign.center,
      ),
    );
  }
}

class PortfolioItemList extends StatelessWidget {
  final List<CryptoStatistic> statistics;
  final String currencyCode;

  const PortfolioItemList({
    super.key,
    required this.statistics,
    required this.currencyCode,
  });

  @override
  Widget build(BuildContext context) {
    final List<Widget> items = [];

    for (int i = 0; i < statistics.length; i++) {
      if (i > 0) {
        items.add(const Divider(height: 1, indent: 16, endIndent: 16));
      }

      items.add(
        PortfolioItemCard(statistic: statistics[i], currencyCode: currencyCode),
      );
    }

    return Column(children: items);
  }
}

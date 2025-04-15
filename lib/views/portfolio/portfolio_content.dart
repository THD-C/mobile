import 'package:flutter/material.dart';
import 'package:mobile/l10n/app_localizations.dart';
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

    final double totalValue = portfolioData.cryptoWalletsStatistics
        .fold(0.0, (sum, stat) => sum + stat.fiatValue);

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
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
            child: PortfolioChart(statistics: portfolioData.cryptoWalletsStatistics),
          ),
          const SizedBox(height: 8),
          ...buildPortfolioItems(context),
        ],
      ),
    );
  }

  List<Widget> buildPortfolioItems(BuildContext context) {
    final List<Widget> items = [];

    for (int i = 0; i < portfolioData.cryptoWalletsStatistics.length; i++) {
      if (i > 0) {
        items.add(const Divider(height: 1, indent: 16, endIndent: 16));
      }

      items.add(
        PortfolioItemCard(
          statistic: portfolioData.cryptoWalletsStatistics[i],
          currencyCode: portfolioData.calculationFiatCurrency,
        ),
      );
    }

    return items;
  }
}
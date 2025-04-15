import 'package:flutter/material.dart';
import 'package:mobile/models/coin.dart';
import 'package:mobile/views/market/market_crypto_list.dart';

class MarketContent extends StatelessWidget {
  final bool isLoading;
  final String? errorMessage;
  final CoinList cryptocurrencies;
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
      child: MarketCryptoList(
        cryptocurrencies: cryptocurrencies,
        onRefresh: onRefresh,
        showPriceRange: showPriceRange,
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:mobile/models/coin.dart';
import 'package:mobile/views/market/market_crypto_list_item.dart';
import 'package:mobile/views/market/market_crypto_detail.dart';

class MarketCryptoList extends StatelessWidget {
  final CoinList cryptocurrencies;
  final Future<void> Function() onRefresh;
  final bool showPriceRange;

  const MarketCryptoList({
    required this.cryptocurrencies,
    required this.onRefresh,
    required this.showPriceRange,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: Padding(
        padding: const EdgeInsets.only(top: 0), // Ensures no extra top padding
        child: ListView.separated(
          itemCount: cryptocurrencies.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          padding: const EdgeInsets.only(top: 0), // Add this line to remove padding at the top of ListView
          itemBuilder: (context, index) {
            final crypto = cryptocurrencies[index];
            return MarketCryptoListItem(
              cryptocurrency: crypto,
              showPriceRange: showPriceRange,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CryptoDetail(cryptocurrency: crypto),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

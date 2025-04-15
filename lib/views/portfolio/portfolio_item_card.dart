import 'package:flutter/material.dart';
import 'package:mobile/models/crypto_statistic.dart';

class PortfolioItemCard extends StatelessWidget {
  final CryptoStatistic statistic;
  final String currencyCode;

  const PortfolioItemCard({
    super.key,
    required this.statistic,
    required this.currencyCode,
  });

  @override
  Widget build(BuildContext context) {
    final cryptoAmount = statistic.fiatValue / statistic.currentPrice;
    final color = getCryptoColor(statistic.cryptocurrency);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  statistic.cryptocurrency[0],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    statistic.cryptocurrency,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${cryptoAmount.toStringAsFixed(6)} ${statistic.cryptocurrency}',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${statistic.fiatValue.toStringAsFixed(2)} ${currencyCode.toUpperCase()}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${statistic.shareInPortfolio.toStringAsFixed(2)}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color getCryptoColor(String cryptocurrency) {
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
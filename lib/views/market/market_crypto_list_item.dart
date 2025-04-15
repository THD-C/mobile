import 'package:flutter/material.dart';
import 'package:mobile/models/coin.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CryptoListItem extends StatelessWidget {
  final Coin cryptocurrency;
  final bool showPriceRange;
  final VoidCallback onTap;

  const CryptoListItem({
    required this.cryptocurrency,
    required this.showPriceRange,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isNegative = cryptocurrency.priceChangePercentage24h < 0;
    final priceChangeText =
        '${isNegative ? "" : "+"}${cryptocurrency.priceChangePercentage24h.toStringAsFixed(2)}%';
    final color = getCryptoColor(cryptocurrency.name);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon section
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: _getCryptoIcon(cryptocurrency),
                ),
              ),
              const SizedBox(width: 16),

              // Name and price change section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cryptocurrency.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (isNegative ? Colors.red : Colors.green).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        priceChangeText,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isNegative ? Colors.red : Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Price section
              // Price section
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (showPriceRange) ...[
                    Row(
                      children: [
                        Text(
                          "Max: ",
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                        Text(
                          '${cryptocurrency.high24h.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          "Min: ",
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                        Text(
                          '${cryptocurrency.low24h.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                  ] else
                    Text(
                      cryptocurrency.currentPrice.toStringAsFixed(2),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getCryptoIcon(Coin crypto) {
    final Map<String, String> cryptoShortCodes = {
      'Bitcoin': 'btc',
      'Ethereum': 'eth',
      'Litecoin': 'ltc',
      'Ripple': 'xrp',
      'Cardano': 'ada',
      'Dogecoin': 'doge',
      'Polkadot': 'dot',
      'Solana': 'sol',
      'Binance Coin': 'bnb',
      'Tether': 'usdt',
    };

    final String shortCode = cryptoShortCodes[crypto.name] ??
        crypto.name.toLowerCase().replaceAll(' ', '_');

    final String svgPath = 'assets/icons/$shortCode.svg';

    return SvgPicture.asset(
      svgPath,
      width: 24,
      height: 24,
      placeholderBuilder: (context) => const Icon(Icons.currency_exchange),
    );
  }

  Color getCryptoColor(String cryptocurrency) {
    final Map<String, Color> colors = {
      'Bitcoin': Colors.orange,
      'Ethereum': Colors.blue,
      'Ripple': Colors.indigo,
      'Tether': Colors.green,
      'Binance Coin': Colors.yellow.shade700,
      'Dogecoin': Colors.amber,
      'Solana': Colors.purple,
      'Cardano': Colors.blue.shade800,
      'Litecoin': Colors.grey.shade800,
    };

    return colors[cryptocurrency] ??
        Colors.primaries[cryptocurrency.hashCode % Colors.primaries.length];
  }
}
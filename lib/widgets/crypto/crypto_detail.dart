import 'package:flutter/material.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/models/coin.dart';

class CryptoDetail extends StatelessWidget {
  final Coin cryptocurrency;

  const CryptoDetail({required this.cryptocurrency, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(cryptocurrency.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildInfoRow(
                      AppLocalizations.of(context).translate('market_price'),
                      '\$${cryptocurrency.currentPrice.toStringAsFixed(2)}',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      AppLocalizations.of(
                        context,
                      ).translate('market_change_24h'),
                      '${cryptocurrency.priceChangePercentage24h > 0 ? "+" : ""}${cryptocurrency.priceChangePercentage24h.toStringAsFixed(2)}%',
                      valueColor:
                          cryptocurrency.priceChangePercentage24h >= 0
                              ? Colors.green
                              : Colors.red,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      '24h Max',
                      '\$${cryptocurrency.high24h.toStringAsFixed(2)}',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      '24h Min',
                      '\$${cryptocurrency.low24h.toStringAsFixed(2)}',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

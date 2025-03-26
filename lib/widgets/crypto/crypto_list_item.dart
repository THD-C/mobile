import 'package:flutter/material.dart';
import 'package:mobile/models/coin.dart';

class CryptoListItem extends StatelessWidget {
  static const double fontSize = 12;

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

    return ListTile(
      leading: CircleAvatar(child: _getCryptoIcon(cryptocurrency)),
      title: Text(
        cryptocurrency.name,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        priceChangeText,
        style: TextStyle(
          color: isNegative ? Colors.red : Colors.green,
          fontWeight: FontWeight.bold,
        ),
      ),
      trailing:
          showPriceRange
              ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Max: ${cryptocurrency.high24h.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: fontSize,
                    ),
                  ),
                  Text(
                    'Min: ${cryptocurrency.low24h.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: fontSize,
                    ),
                  ),
                ],
              )
              : Text(
                cryptocurrency.currentPrice.toStringAsFixed(2),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: fontSize,
                ),
              ),
      onTap: onTap,
    );
  }

  Widget _getCryptoIcon(Coin crypto) {
    final Map<String, IconData> cryptoIcons = {
      'Bitcoin': Icons.currency_bitcoin,
      'Ethereum': Icons.currency_exchange,
      'Litecoin': Icons.currency_bitcoin,
      'Ripple': Icons.currency_bitcoin,
      'Cardano': Icons.currency_bitcoin,
      'Dogecoin': Icons.currency_bitcoin,
      'Polkadot': Icons.currency_bitcoin,
      'Solana': Icons.currency_bitcoin,
      'Binance Coin': Icons.currency_bitcoin,
      'Tether': Icons.currency_bitcoin,
    };

    final IconData iconData =
        cryptoIcons[crypto.name] ?? Icons.currency_exchange;

    return Icon(iconData);
  }
}

import 'package:flutter/material.dart';
import 'package:mobile/models/crypto_currency.dart';

class CryptoListItem extends StatelessWidget {
  static const double fontSize = 12;

  final CryptoCurrency cryptocurrency;
  final bool showPriceRange;
  final VoidCallback onTap; // Add onTap callback

  const CryptoListItem({
    required this.cryptocurrency,
    required this.showPriceRange,
    required this.onTap, // Make it required
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
                    'High: \$${cryptocurrency.high24h.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: fontSize,
                    ),
                  ),
                  Text(
                    'Low: \$${cryptocurrency.low24h.toStringAsFixed(2)}',
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
      onTap: onTap, // Add the onTap handler here
    );
  }

  Widget _getCryptoIcon(CryptoCurrency crypto) {
    // Map common cryptocurrencies to appropriate icons
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

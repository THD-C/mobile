import 'package:flutter/material.dart';
import 'package:mobile/models/coin.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
}

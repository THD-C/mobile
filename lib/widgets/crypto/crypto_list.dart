import 'package:flutter/material.dart';
import 'package:mobile/models/crypto_currency.dart';
import 'package:mobile/widgets/crypto/crypto_list_item.dart';
import 'package:mobile/widgets/crypto/crypto_detail.dart';

class CryptoListView extends StatelessWidget {
  final CryptoCurrencyList cryptocurrencies;
  final Future<void> Function() onRefresh;
  final bool showPriceRange;

  const CryptoListView({
    required this.cryptocurrencies,
    required this.onRefresh,
    required this.showPriceRange,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        itemCount: cryptocurrencies.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final crypto = cryptocurrencies[index];
          return CryptoListItem(
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
    );
  }
}

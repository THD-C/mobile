class CoinData {
  final String id;
  final String symbol;
  final String name;
  final double currentPrice;
  final double high24h;
  final double low24h;
  final double priceChange24h;
  final double priceChangePercentage24h;
  final double marketCap;
  final double totalVolume;

  CoinData({
    required this.id,
    required this.symbol,
    required this.name,
    required this.currentPrice,
    required this.high24h,
    required this.low24h,
    required this.priceChange24h,
    required this.priceChangePercentage24h,
    required this.marketCap,
    required this.totalVolume,
  });

  // Named constructor providing default values.
  CoinData.empty()
    : id = '',
      symbol = '',
      name = '',
      currentPrice = 0.0,
      high24h = 0.0,
      low24h = 0.0,
      priceChange24h = 0.0,
      priceChangePercentage24h = 0.0,
      marketCap = 0.0,
      totalVolume = 0.0;

  factory CoinData.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final marketData = data['market_data'];

    return CoinData(
      id: data['id'],
      symbol: data['symbol'],
      name: data['name'],
      currentPrice: (marketData['current_price'] as num).toDouble(),
      high24h: (marketData['high_24h'] as num).toDouble(),
      low24h: (marketData['low_24h'] as num).toDouble(),
      priceChange24h:
          (marketData['price_change_24h_in_currency'] as num).toDouble(),
      priceChangePercentage24h:
          (marketData['price_change_percentage_24h_in_currency'] as num)
              .toDouble(),
      marketCap: (marketData['market_cap'] as num).toDouble(),
      totalVolume: (marketData['total_volume'] as num).toDouble(),
    );
  }
}

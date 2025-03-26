class Coin {
  final String id;
  final String name;
  final String symbol;
  final double currentPrice;
  final double priceChangePercentage24h;
  final double high24h;
  final double low24h;

  Coin({
    required this.id,
    required this.name,
    required this.symbol,
    required this.currentPrice,
    required this.priceChangePercentage24h,
    required this.high24h,
    required this.low24h,
  });

  factory Coin.fromJson(Map<String, dynamic> coinObject) {
    String coinKey = coinObject.keys.first;
    var coinData = coinObject[coinKey];
    var marketData = coinData['market_data'];

    return Coin(
      id: coinData['id'],
      name: coinData['name'],
      symbol: coinData['symbol'],
      currentPrice: marketData['current_price'].toDouble(),
      priceChangePercentage24h:
          marketData['price_change_percentage_24h_in_currency'].toDouble(),
      high24h: marketData['high_24h'].toDouble(),
      low24h: marketData['low_24h'].toDouble(),
    );
  }
}

class CoinList {
  final List<Coin> cryptocurrencies;

  CoinList({required this.cryptocurrencies});

  factory CoinList.fromJson(Map<String, dynamic> json) {
    var coinsJson = json['coins'] as List;
    List<Coin> coinsList =
        coinsJson.map((coinJson) => Coin.fromJson(coinJson)).toList();

    return CoinList(cryptocurrencies: coinsList);
  }

  static empty() {
    return CoinList(cryptocurrencies: []);
  }

  int get length => cryptocurrencies.length;

  Coin operator [](int index) => cryptocurrencies[index];
}

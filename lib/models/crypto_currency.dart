class CryptoCurrency {
  final String id;
  final String name;
  final String symbol;
  final double currentPrice;
  final double priceChangePercentage24h;
  final double high24h;
  final double low24h;

  CryptoCurrency({
    required this.id,
    required this.name,
    required this.symbol,
    required this.currentPrice,
    required this.priceChangePercentage24h,
    required this.high24h,
    required this.low24h,
  });

  factory CryptoCurrency.fromJson(Map<String, dynamic> coinObject) {
    String coinKey = coinObject.keys.first;
    var coinData = coinObject[coinKey];
    var marketData = coinData['market_data'];

    return CryptoCurrency(
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

class CryptoCurrencyList {
  final List<CryptoCurrency> cryptocurrencies;

  CryptoCurrencyList({required this.cryptocurrencies});

  factory CryptoCurrencyList.fromJson(Map<String, dynamic> json) {
    var coinsJson = json['coins'] as List;
    List<CryptoCurrency> coinsList =
        coinsJson.map((coinJson) => CryptoCurrency.fromJson(coinJson)).toList();

    return CryptoCurrencyList(cryptocurrencies: coinsList);
  }

  static empty() {
    return CryptoCurrencyList(cryptocurrencies: []);
  }

  int get length => cryptocurrencies.length;

  CryptoCurrency operator [](int index) => cryptocurrencies[index];
}

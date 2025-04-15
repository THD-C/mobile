class CryptoStatistic {
  final String cryptocurrency;
  final double fiatValue;
  final double currentPrice;
  final double shareInPortfolio;

  CryptoStatistic({
    required this.cryptocurrency,
    required this.fiatValue,
    required this.currentPrice,
    required this.shareInPortfolio,
  });

  factory CryptoStatistic.fromJson(Map<String, dynamic> json) {
    return CryptoStatistic(
      cryptocurrency: json['cryptocurrency'],
      fiatValue: json['fiat_value'].toDouble(),
      currentPrice: json['current_price'].toDouble(),
      shareInPortfolio: json['share_in_portfolio'].toDouble(),
    );
  }
}

class CryptoStatisticList {
  final List<CryptoStatistic> statistics;

  CryptoStatisticList({required this.statistics});

  factory CryptoStatisticList.fromJson(Map<String, dynamic> json) {
    var statsJson = json['statistics'] as List;
    List<CryptoStatistic> statsList = statsJson
        .map((statJson) => CryptoStatistic.fromJson(statJson))
        .toList();

    return CryptoStatisticList(statistics: statsList);
  }

  static empty() {
    return CryptoStatisticList(statistics: []);
  }

  int get length => statistics.length;

  CryptoStatistic operator [](int index) => statistics[index];
}

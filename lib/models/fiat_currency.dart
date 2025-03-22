class FiatCurrency {
  final String name;

  FiatCurrency({required this.name});

  factory FiatCurrency.fromJson(Map<String, dynamic> json) {
    return FiatCurrency(name: json['currency_name']);
  }
}

class FiatCurrencyList {
  final List<FiatCurrency> currencies;

  FiatCurrencyList({required this.currencies});

  static empty() {
    return FiatCurrencyList(currencies: []);
  }

  int get length => currencies.length;

  FiatCurrency operator [](int index) => currencies[index];

  factory FiatCurrencyList.fromJson(Map<String, dynamic> json) {
    var currenciesJson = json['currencies'] as List;
    List<FiatCurrency> currenciesList =
        currenciesJson
            .map((currencyJson) => FiatCurrency.fromJson(currencyJson))
            .toList();

    return FiatCurrencyList(currencies: currenciesList);
  }
}

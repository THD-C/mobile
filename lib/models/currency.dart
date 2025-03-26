class Currency {
  final String name;

  Currency({required this.name});

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(name: json['currency_name']);
  }
}

class CurrencyList {
  final List<Currency> currencies;

  CurrencyList({required this.currencies});

  static empty() {
    return CurrencyList(currencies: []);
  }

  int get length => currencies.length;

  Currency operator [](int index) => currencies[index];

  factory CurrencyList.fromJson(Map<String, dynamic> json) {
    var currenciesJson = json['currencies'] as List;
    List<Currency> currenciesList =
        currenciesJson
            .map((currencyJson) => Currency.fromJson(currencyJson))
            .toList();

    currenciesList.sort((a, b) => a.name.compareTo(b.name));

    return CurrencyList(currencies: currenciesList);
  }
}

enum CurrencyType {
  NOT_SUPPORTED,
  FIAT,
  CRYPTO;

  @override
  String toString() => this.name;
}

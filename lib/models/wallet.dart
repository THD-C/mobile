class Wallet {
  final String id;
  final String currency;
  final double value;
  final bool isCrypto;

  Wallet({
    required this.id,
    required this.currency,
    required this.value,
    required this.isCrypto,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['id'],
      currency: json['currency'],
      value: double.parse(json['value'].toString()),
      isCrypto: json['is_crypto'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'currency': currency,
      'value': value.toString(),
      'is_crypto': isCrypto,
    };
  }
}

class WalletList {
  final List<Wallet> wallets;

  WalletList({required this.wallets});

  static WalletList empty() {
    return WalletList(wallets: []);
  }

  int get length => wallets.length;

  Wallet operator [](int index) => wallets[index];

  factory WalletList.fromJson(Map<String, dynamic> json) {
    var walletsJson = json['wallets'] as List;
    List<Wallet> walletsList =
        walletsJson.map((walletJson) => Wallet.fromJson(walletJson)).toList();

    return WalletList(wallets: walletsList);
  }

  Map<String, dynamic> toJson() {
    return {'wallets': wallets.map((wallet) => wallet.toJson()).toList()};
  }
}

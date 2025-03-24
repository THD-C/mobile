class AppConfig {
  static final AppConfig _instance = AppConfig._internal();

  factory AppConfig() {
    return _instance;
  }

  AppConfig._internal();

  String _apiBaseUrl = 'http://10.0.2.2:80/api';

  String get fiatApiUrl => '$_apiBaseUrl/currency';

  String get cryptoApiUrl => '$_apiBaseUrl/crypto';

  String get walletApiUrl => '$_apiBaseUrl/wallets';

  String get userApiUrl => '$_apiBaseUrl/user';

  void initialize({String? apiBaseUrl}) {
    if (apiBaseUrl != null) {
      _apiBaseUrl = apiBaseUrl;
    }
  }
}

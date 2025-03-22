class AppConfig {
  static final AppConfig _instance = AppConfig._internal();

  factory AppConfig() {
    return _instance;
  }

  AppConfig._internal();

  String _apiBaseUrl = 'http://thdc/api';

  String get fiatApiUrl => '$_apiBaseUrl/currency';

  String get cryptoApiUrl => '$_apiBaseUrl/crypto';

  String get walletApiUrl => '$_apiBaseUrl/wallets';

  void initialize({String? apiBaseUrl}) {
    if (apiBaseUrl != null) {
      _apiBaseUrl = apiBaseUrl;
    }
  }
}

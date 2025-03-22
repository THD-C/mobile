class AppConfig {
  static final AppConfig _instance = AppConfig._internal();

  factory AppConfig() {
    return _instance;
  }

  AppConfig._internal();

  String _apiBaseUrl = 'http://thdc';

  String get fiatApiUrl => '$_apiBaseUrl/api/currency';

  String get cryptoApiUrl => '$_apiBaseUrl/api/crypto';

  String get walletApiUrl => '$_apiBaseUrl/api/wallets';

  void initialize({String? apiBaseUrl}) {
    if (apiBaseUrl != null) {
      _apiBaseUrl = apiBaseUrl;
    }
  }
}

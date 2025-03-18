import 'package:shared_preferences/shared_preferences.dart';

class TokenHandler {
  static Future<String?> loadToken() async{
    final prefs = await SharedPreferences.getInstance();
    String? token;
    token = prefs.getString('jwt_token');
    return token;
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
  }
}
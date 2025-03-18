import 'package:flutter/material.dart';
import 'package:mobile/pages/login_screen.dart';
import 'package:mobile/pages/main_page.dart';
import 'package:mobile/pages/register_screen.dart';

class Navigators {
   static void navigateToHome(BuildContext context) async {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  static void navigateToRegister(BuildContext context) async{
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const RegisterScreen()),
    );
  }

  static void navigateToLogin(BuildContext context) async{
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }
}
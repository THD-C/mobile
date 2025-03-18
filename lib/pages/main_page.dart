import 'package:flutter/material.dart';
import 'package:mobile/tools/navigators.dart';
import 'package:mobile/tools/token_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Strona główna')
      ),
      body: ElevatedButton(
                  onPressed: () {TokenHandler.saveToken("");
                  Navigators.navigateToLogin(context);},
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: 
                      const Text(
                          'Wyloguj',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
    );
  }
      
  
}
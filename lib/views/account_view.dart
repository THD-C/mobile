import 'package:flutter/material.dart';
import 'package:mobile/tools/navigators.dart';
import 'package:mobile/tools/token_handler.dart';

class AccountView extends StatelessWidget {
  const AccountView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      
      child: Column(
        
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Text(
            'Profil użytkownika',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          
          FilledButton(
            onPressed: () {
              TokenHandler.saveToken("");
              Navigators.navigateToLogin(context);
            },

            child: const Text('Wyloguj', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }
}

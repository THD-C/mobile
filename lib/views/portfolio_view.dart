import 'package:flutter/material.dart';

// PONIŻSZA KLASA POWINNA EXTENDOWAĆ StatefulWidget
class PortfolioView extends StatelessWidget {
  const PortfolioView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Portfolio',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';

// PONIŻSZA KLASA POWINNA EXTENDOWAĆ StatefulWidget
class MarketsView extends StatelessWidget {
  const MarketsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Markets',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

        ],
      ),
    );
  }
}
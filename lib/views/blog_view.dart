import 'package:flutter/material.dart';


class BlogView extends StatelessWidget {
  const BlogView({super.key});

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
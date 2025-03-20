import 'package:flutter/material.dart';

import 'package:mobile/views/account_view.dart';
import 'package:mobile/views/blog_view.dart';
import 'package:mobile/views/markets_view.dart';
import 'package:mobile/views/portfolio_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    const MarketsView(),
    const BlogView(),
    const PortfolioView(),
    const AccountView(),
  ];

  void _onItemClicked(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemClicked,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Markets"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Blog"),
          BottomNavigationBarItem(icon: Icon(Icons.wallet), label: "Portfolio"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Account"),
        
        ],
      ),
    );
  }
}

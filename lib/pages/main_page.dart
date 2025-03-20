import 'package:flutter/material.dart';
import 'package:mobile/l10n/app_localizations.dart';

import 'package:mobile/views/account_view.dart';
import 'package:mobile/views/blog/blog_view.dart';
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
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.candlestick_chart),
            label: AppLocalizations.of(
              context,
            ).translate('main_navigation_bar_market'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.my_library_books),
            label: AppLocalizations.of(
              context,
            ).translate('main_navigation_bar_blog'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.wallet),
            label: AppLocalizations.of(
              context,
            ).translate('main_navigation_bar_portfolio'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: AppLocalizations.of(
              context,
            ).translate('main_navigation_bar_account'),
          ),
        ],
      ),
    );
  }
}

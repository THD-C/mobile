import 'dart:ui';

import 'package:flutter/material.dart';

import 'market_selector_container.dart';

class ViewTypeSelector extends StatelessWidget {
  final bool showPriceRange;
  final VoidCallback onToggleView;

  const ViewTypeSelector({
    super.key,
    required this.showPriceRange,
    required this.onToggleView,
  });

  @override
  Widget build(BuildContext context) {
    return SelectorContainer(
      child: DropdownButton<bool>(
        value: showPriceRange,
        underline: Container(),
        icon: const Icon(Icons.keyboard_arrow_down, size: 20),
        borderRadius: BorderRadius.circular(8),
        items: [
          DropdownMenuItem<bool>(
            value: false,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.show_chart, size: 18),
                SizedBox(width: 8),
                Text('Price', style: TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          DropdownMenuItem<bool>(
            value: true,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.bar_chart, size: 18),
                SizedBox(width: 8),
                Text('Range', style: TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
        onChanged: (_) => onToggleView(),
      ),
    );
  }
}

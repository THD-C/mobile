import 'package:flutter/material.dart';

class ChangeViewButton extends StatelessWidget {
  final bool showPriceRange;
  final VoidCallback onToggleView;

  const ChangeViewButton({
    super.key,
    required this.showPriceRange,
    required this.onToggleView,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onToggleView,
      icon: const Icon(Icons.list, color: Colors.white),
      label: const Text('Change View', style: TextStyle(color: Colors.white)),
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}

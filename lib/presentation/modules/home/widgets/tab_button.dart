import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class TabButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final bool isAccent;

  const TabButton({
    super.key,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.isAccent = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? (isAccent ? AppTheme.primary : AppTheme.surfaceHighlight)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive
                ? (isAccent ? Colors.black : Colors.white)
                : AppTheme.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

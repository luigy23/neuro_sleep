import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class BentoCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? color;
  final BorderSide? border;
  final EdgeInsetsGeometry padding;

  const BentoCard({
    super.key,
    required this.child,
    this.onTap,
    this.color,
    this.border,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: color ?? AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.fromBorderSide(
            border ??
                BorderSide(
                  color: AppTheme.surfaceHighlight.withValues(alpha: 0.5),
                ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

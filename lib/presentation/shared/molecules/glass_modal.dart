import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class GlassModal extends StatelessWidget {
  final Widget child;
  final VoidCallback onClose;

  const GlassModal({super.key, required this.child, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: onClose,
          child: Container(color: Colors.black.withValues(alpha: 0.8)),
        ),
        Center(
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.surface.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.surfaceHighlight),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: child,
          ),
        ),
      ],
    );
  }
}

import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class TimerPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0
  final Color color;
  final Color backgroundColor;

  TimerPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;
    final strokeWidth = 8.0;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius - strokeWidth / 2, bgPaint);

    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      -pi / 2, // Start from top
      sweepAngle,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant TimerPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

class CircularTimer extends StatelessWidget {
  final int totalSeconds;
  final int remainingSeconds;
  final bool isFinished;

  const CircularTimer({
    super.key,
    required this.totalSeconds,
    required this.remainingSeconds,
    required this.isFinished,
  });

  String get formattedTime {
    final m = (remainingSeconds / 60).floor();
    final s = remainingSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final progress = totalSeconds == 0 ? 0.0 : remainingSeconds / totalSeconds;

    return SizedBox(
      width: 240,
      height: 240,
      child: Stack(
        children: [
          CustomPaint(
            size: const Size(240, 240),
            painter: TimerPainter(
              progress: progress,
              color: isFinished ? AppTheme.success : AppTheme.primary,
              backgroundColor: AppTheme.surfaceHighlight,
            ),
          ),
          Center(
            child: Text(
              formattedTime,
              style: const TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.bold,
                fontFamily:
                    'Monospace', // Or use GoogleFonts.spaceMono if added
                letterSpacing: -2,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

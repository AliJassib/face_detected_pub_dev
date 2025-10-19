import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Custom painter for circle overlay with transparent center
class CircleOverlayPainter extends CustomPainter {
  final double circleRadius;
  final Color overlayColor;
  final double animationProgress; // 0.0 to 1.0

  CircleOverlayPainter({
    required this.circleRadius,
    required this.overlayColor,
    required this.animationProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final animatedRadius = circleRadius * animationProgress;

    // Draw black overlay with hole in center
    final overlayPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addOval(Rect.fromCircle(center: center, radius: animatedRadius))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, overlayPaint);

    // Draw circle border with gradient
    final borderPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withOpacity(0.8),
          Colors.blue.withOpacity(0.6),
          Colors.white.withOpacity(0.8),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: animatedRadius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.0;

    canvas.drawCircle(center, animatedRadius, borderPaint);

    // Draw decorative lines around the circle
    _drawDecorativeLines(canvas, center, animatedRadius);
  }

  void _drawDecorativeLines(Canvas canvas, Offset center, double radius) {
    final linePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..color = Colors.blue.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.0
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);

    // Draw lines at 20 positions around the circle
    for (int i = 0; i < 20; i++) {
      final angle = (i * 2 * math.pi / 20) - math.pi / 2;

      // Calculate position on circle edge
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);

      // Calculate line start and end points (outward from circle)
      final lineLength = 25.0;
      final startX = x + (lineLength / 2) * math.cos(angle);
      final startY = y + (lineLength / 2) * math.sin(angle);
      final endX = x - (lineLength / 2) * math.cos(angle);
      final endY = y - (lineLength / 2) * math.sin(angle);

      final start = Offset(startX, startY);
      final end = Offset(endX, endY);

      // Draw glow
      canvas.drawLine(start, end, glowPaint);

      // Draw main line
      canvas.drawLine(start, end, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CircleOverlayPainter oldDelegate) {
    return oldDelegate.circleRadius != circleRadius ||
        oldDelegate.overlayColor != overlayColor ||
        oldDelegate.animationProgress != animationProgress;
  }
}

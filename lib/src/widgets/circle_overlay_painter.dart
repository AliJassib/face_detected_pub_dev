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
      ..strokeWidth = 3.0;

    canvas.drawCircle(center, animatedRadius, borderPaint);

    // Draw decorative lines around the circle
    _drawDecorativeLines(canvas, center, animatedRadius);
  }

  void _drawDecorativeLines(Canvas canvas, Offset center, double radius) {
    final linePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..color = Colors.blue.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);

    // Draw lines at 8 positions around the circle
    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi / 4) - math.pi / 2;

      // Calculate position on circle edge
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);

      // Calculate line start and end points (outward from circle)
      final lineLength = 20.0;
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

    // Draw corner brackets at 4 main positions
    _drawCornerBrackets(canvas, center, radius);
  }

  void _drawCornerBrackets(Canvas canvas, Offset center, double radius) {
    final bracketPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..color = Colors.blue.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0);

    // Draw brackets at 4 main positions (top, right, bottom, left)
    for (int i = 0; i < 4; i++) {
      final angle = i * math.pi / 2;

      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);

      final bracketSize = 30.0;
      final bracketOffset = 15.0;

      // Calculate bracket points
      final outerPoint = Offset(
        x + bracketOffset * math.cos(angle),
        y + bracketOffset * math.sin(angle),
      );

      final leftPoint = Offset(
        outerPoint.dx + bracketSize * math.cos(angle + math.pi / 2),
        outerPoint.dy + bracketSize * math.sin(angle + math.pi / 2),
      );

      final rightPoint = Offset(
        outerPoint.dx + bracketSize * math.cos(angle - math.pi / 2),
        outerPoint.dy + bracketSize * math.sin(angle - math.pi / 2),
      );

      // Draw bracket path
      final path = Path()
        ..moveTo(leftPoint.dx, leftPoint.dy)
        ..lineTo(outerPoint.dx, outerPoint.dy)
        ..lineTo(rightPoint.dx, rightPoint.dy);

      // Draw glow
      canvas.drawPath(path, glowPaint);

      // Draw main bracket
      canvas.drawPath(path, bracketPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CircleOverlayPainter oldDelegate) {
    return oldDelegate.circleRadius != circleRadius ||
        oldDelegate.overlayColor != overlayColor ||
        oldDelegate.animationProgress != animationProgress;
  }
}

import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../models/face_data.dart';

/// Custom painter to draw face landmarks, contours, and bounding box
class FaceLandmarksPainter extends CustomPainter {
  final List<FaceData> faces;
  final ui.Size cameraPreviewSize;
  final Size screenSize;
  final double animationProgress; // 0.0 to 1.0

  FaceLandmarksPainter({
    required this.faces,
    required this.cameraPreviewSize,
    required this.screenSize,
    required this.animationProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final faceData in faces) {
      final face = faceData.originalFace;
      if (face == null) continue;

      // Draw animated face mesh with contours
      _drawAnimatedFaceMesh(
        canvas,
        face.landmarks,
        face.contours,
        size,
        animationProgress,
      );
    }
  }

  /// Draw animated face mesh with separate point groups and contours
  void _drawAnimatedFaceMesh(
    Canvas canvas,
    Map<FaceLandmarkType, FaceLandmark?> landmarks,
    Map<FaceContourType, FaceContour?> contours,
    Size size,
    double progress,
  ) {
    final validLandmarks = landmarks.entries
        .where((entry) => entry.value != null)
        .map((entry) => MapEntry(entry.key, entry.value!))
        .toList();

    if (validLandmarks.isEmpty) return;

    // Animation phases (total 4 seconds):
    // 0.0 - 0.35: Draw all points (landmarks + contours) - 1.4s
    // 0.35 - 0.85: Draw connecting lines - 2.0s
    // 0.85 - 1.0: Fade out everything - 0.6s

    final pointsPhase = (progress / 0.35).clamp(0.0, 1.0);
    final linesPhase = ((progress - 0.35) / 0.5).clamp(0.0, 1.0);
    final fadeOutPhase = ((progress - 0.85) / 0.15).clamp(0.0, 1.0);

    final opacity = 1.0 - fadeOutPhase;

    // Phase 1: Draw points (landmarks + contours)
    if (progress < 0.85) {
      // Draw landmark points
      _drawLandmarkPoints(canvas, validLandmarks, size, pointsPhase, opacity);

      // Draw contour points (MORE POINTS!)
      _drawContourPoints(canvas, contours, size, pointsPhase, opacity);
    }

    // Phase 2: Draw connecting lines
    if (progress >= 0.35 && progress < 0.85) {
      _drawAnimatedConnections(
        canvas,
        validLandmarks,
        contours,
        size,
        linesPhase,
        opacity,
      );
    }
  }

  /// Draw all landmark points at once
  void _drawLandmarkPoints(
    Canvas canvas,
    List<MapEntry<FaceLandmarkType, FaceLandmark>> landmarks,
    Size size,
    double progress,
    double opacity,
  ) {
    for (final landmark in landmarks) {
      final position = _scalePoint(
        Offset(
          landmark.value.position.x.toDouble(),
          landmark.value.position.y.toDouble(),
        ),
        size,
      );

      if (progress > 0) {
        // All landmarks in green
        final pointPaint = Paint()
          ..color = const Color(
            0xFF4CAF50,
          ).withValues(alpha: progress * opacity)
          ..style = PaintingStyle.fill;

        final glowPaint = Paint()
          ..color = const Color(
            0xFF4CAF50,
          ).withValues(alpha: progress * opacity * 0.3)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);

        // Draw glow
        canvas.drawCircle(position, 8.0 * progress, glowPaint);

        // Draw main point
        canvas.drawCircle(position, 6.0 * progress, pointPaint);

        // Draw white center
        final centerPaint = Paint()
          ..color = Colors.white.withValues(alpha: progress * opacity * 0.8)
          ..style = PaintingStyle.fill;

        canvas.drawCircle(position, 2.0 * progress, centerPaint);
      }
    }
  }

  /// Draw all contour points (LOTS OF POINTS!)
  void _drawContourPoints(
    Canvas canvas,
    Map<FaceContourType, FaceContour?> contours,
    Size size,
    double progress,
    double opacity,
  ) {
    contours.forEach((type, contour) {
      if (contour != null && contour.points.isNotEmpty) {
        for (final point in contour.points) {
          final position = _scalePoint(
            Offset(point.x.toDouble(), point.y.toDouble()),
            size,
          );

          if (progress > 0) {
            // All contour points in green
            final pointPaint = Paint()
              ..color = const Color(
                0xFF4CAF50,
              ).withValues(alpha: progress * opacity)
              ..style = PaintingStyle.fill;

            final glowPaint = Paint()
              ..color = const Color(
                0xFF4CAF50,
              ).withValues(alpha: progress * opacity * 0.2)
              ..style = PaintingStyle.fill
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);

            // Draw glow
            canvas.drawCircle(position, 5.0 * progress, glowPaint);

            // Draw main point (smaller for contours)
            canvas.drawCircle(position, 3.0 * progress, pointPaint);

            // Draw white center
            final centerPaint = Paint()
              ..color = Colors.white.withValues(alpha: progress * opacity * 0.6)
              ..style = PaintingStyle.fill;

            canvas.drawCircle(position, 1.0 * progress, centerPaint);
          }
        }
      }
    });
  }

  /// Draw animated connections between points (landmarks + contours)
  void _drawAnimatedConnections(
    Canvas canvas,
    List<MapEntry<FaceLandmarkType, FaceLandmark>> landmarks,
    Map<FaceContourType, FaceContour?> contours,
    Size size,
    double progress,
    double opacity,
  ) {
    final landmarkPositions = <FaceLandmarkType, Offset>{};

    // Get all landmark positions
    for (final entry in landmarks) {
      final position = _scalePoint(
        Offset(
          entry.value.position.x.toDouble(),
          entry.value.position.y.toDouble(),
        ),
        size,
      );
      landmarkPositions[entry.key] = position;
    }

    // Get all contour positions
    final contourPositions = <List<Offset>>[];
    contours.forEach((type, contour) {
      if (contour != null && contour.points.isNotEmpty) {
        final points = contour.points.map((point) {
          return _scalePoint(
            Offset(point.x.toDouble(), point.y.toDouble()),
            size,
          );
        }).toList();
        contourPositions.add(points);
      }
    });

    final yellow = const Color(0xFFFFEB3B); // Yellow color

    // Draw landmark connections
    _drawLandmarkConnections(
      canvas,
      landmarkPositions,
      progress,
      opacity,
      yellow,
    );

    // Draw contour connections (connecting contour points)
    _drawContourConnections(
      canvas,
      contourPositions,
      progress,
      opacity,
      yellow,
    );
  }

  /// Draw connections between landmarks
  void _drawLandmarkConnections(
    Canvas canvas,
    Map<FaceLandmarkType, Offset> positions,
    double progress,
    double opacity,
    Color color,
  ) {
    // Define landmark connections
    final connections = [
      [FaceLandmarkType.leftEye, FaceLandmarkType.rightEye],
      [FaceLandmarkType.leftEye, FaceLandmarkType.noseBase],
      [FaceLandmarkType.rightEye, FaceLandmarkType.noseBase],
      [FaceLandmarkType.noseBase, FaceLandmarkType.leftMouth],
      [FaceLandmarkType.noseBase, FaceLandmarkType.rightMouth],
      [FaceLandmarkType.leftMouth, FaceLandmarkType.rightMouth],
      [FaceLandmarkType.leftEye, FaceLandmarkType.leftMouth],
      [FaceLandmarkType.rightEye, FaceLandmarkType.rightMouth],
    ];

    for (final connection in connections) {
      final startPos = positions[connection[0]];
      final endPos = positions[connection[1]];

      if (startPos != null && endPos != null) {
        _drawAnimatedLine(canvas, startPos, endPos, color, progress, opacity);
      }
    }
  }

  /// Draw connections between contour points
  void _drawContourConnections(
    Canvas canvas,
    List<List<Offset>> contours,
    double progress,
    double opacity,
    Color color,
  ) {
    for (final contour in contours) {
      for (int i = 0; i < contour.length - 1; i++) {
        _drawAnimatedLine(
          canvas,
          contour[i],
          contour[i + 1],
          color,
          progress,
          opacity,
        );
      }
    }
  }

  /// Draw animated line from start to end position
  void _drawAnimatedLine(
    Canvas canvas,
    Offset start,
    Offset end,
    Color color,
    double progress,
    double opacity,
  ) {
    // Calculate current end position based on progress
    final currentEnd = Offset.lerp(start, end, progress)!;

    // Create line paint

    final linePaint = Paint()
      ..color = color.withValues(alpha: progress * opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    // Create glow paint
    final glowPaint = Paint()
      ..color = color.withValues(alpha: progress * opacity * 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);

    // Draw glow
    canvas.drawLine(start, currentEnd, glowPaint);

    // Draw main line
    canvas.drawLine(start, currentEnd, linePaint);
  }

  /// Scale point from camera coordinates to screen coordinates
  Offset _scalePoint(Offset point, Size size) {
    // Calculate BoxFit.cover scale and offset
    final double previewAspectRatio =
        cameraPreviewSize.width / cameraPreviewSize.height;
    final double screenAspectRatio = size.width / size.height;

    double scale;
    double offsetX = 0;
    double offsetY = 0;

    if (previewAspectRatio > screenAspectRatio) {
      // Preview is wider - fit height, crop width
      scale = size.height / cameraPreviewSize.height;
      offsetX = (cameraPreviewSize.width * scale - size.width) / 2;
    } else {
      // Preview is taller - fit width, crop height
      scale = size.width / cameraPreviewSize.width;
      offsetY = (cameraPreviewSize.height * scale - size.height) / 2;
    }

    // Apply transformation
    if (Platform.isIOS) {
      // iOS front camera: rotated 270°
      return Offset(
        size.width - (point.dy * scale - offsetX),
        point.dx * scale - offsetY,
      );
    } else {
      // Android front camera: mirrored
      return Offset(
        size.width - (point.dx * scale - offsetX),
        point.dy * scale - offsetY,
      );
    }
  }

  @override
  bool shouldRepaint(covariant FaceLandmarksPainter oldDelegate) {
    return oldDelegate.faces != faces ||
        oldDelegate.cameraPreviewSize != cameraPreviewSize ||
        oldDelegate.screenSize != screenSize ||
        oldDelegate.animationProgress != animationProgress;
  }
}

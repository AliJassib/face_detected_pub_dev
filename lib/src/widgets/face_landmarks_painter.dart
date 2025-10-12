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

  FaceLandmarksPainter({
    required this.faces,
    required this.cameraPreviewSize,
    required this.screenSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final faceData in faces) {
      final face = faceData.originalFace;
      if (face == null) continue;

      // Draw bounding box
      _drawBoundingBox(canvas, face.boundingBox, size);

      // Draw landmarks
      _drawLandmarks(canvas, face.landmarks, size);

      // Draw contours
      _drawContours(canvas, face.contours, size);
    }
  }

  /// Draw bounding box around the face
  void _drawBoundingBox(Canvas canvas, Rect boundingBox, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final rect = _scaleRect(boundingBox, size);
    canvas.drawRect(rect, paint);

    // Draw corner indicators for better visibility
    final cornerPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;

    final cornerSize = 8.0;
    // Top-left corner
    canvas.drawCircle(rect.topLeft, cornerSize, cornerPaint);
    // Top-right corner
    canvas.drawCircle(rect.topRight, cornerSize, cornerPaint);
    // Bottom-left corner
    canvas.drawCircle(rect.bottomLeft, cornerSize, cornerPaint);
    // Bottom-right corner
    canvas.drawCircle(rect.bottomRight, cornerSize, cornerPaint);
  }

  /// Draw face landmarks (key points)
  void _drawLandmarks(
    Canvas canvas,
    Map<FaceLandmarkType, FaceLandmark?> landmarks,
    Size size,
  ) {
    final landmarkPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    final landmarkBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    landmarks.forEach((type, landmark) {
      if (landmark != null) {
        final position = _scalePoint(
          Offset(
            landmark.position.x.toDouble(),
            landmark.position.y.toDouble(),
          ),
          size,
        );

        // Draw white border
        canvas.drawCircle(position, 6.0, landmarkBorderPaint);
        // Draw red point
        canvas.drawCircle(position, 4.5, landmarkPaint);

        // Draw label for key landmarks (optional)
        _drawLandmarkLabel(canvas, type, position);
      }
    });
  }

  /// Draw landmark labels for better understanding
  void _drawLandmarkLabel(
    Canvas canvas,
    FaceLandmarkType type,
    Offset position,
  ) {
    String? label;
    switch (type) {
      case FaceLandmarkType.leftEye:
        label = 'LE';
        break;
      case FaceLandmarkType.rightEye:
        label = 'RE';
        break;
      case FaceLandmarkType.noseBase:
        label = 'N';
        break;
      case FaceLandmarkType.leftMouth:
        label = 'LM';
        break;
      case FaceLandmarkType.rightMouth:
        label = 'RM';
        break;
      default:
        return; // Don't draw labels for other landmarks
    }

    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(color: Colors.black, offset: Offset(1, 1), blurRadius: 2),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(position.dx - textPainter.width / 2, position.dy - 20),
    );
  }

  /// Draw face contours (detailed face shape)
  void _drawContours(
    Canvas canvas,
    Map<FaceContourType, FaceContour?> contours,
    Size size,
  ) {
    contours.forEach((type, contour) {
      if (contour != null && contour.points.isNotEmpty) {
        final paint = Paint()
          ..color = _getContourColor(type)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0
          ..strokeCap = StrokeCap.round;

        final path = Path();
        final firstPoint = _scalePoint(
          Offset(
            contour.points.first.x.toDouble(),
            contour.points.first.y.toDouble(),
          ),
          size,
        );

        path.moveTo(firstPoint.dx, firstPoint.dy);

        for (int i = 1; i < contour.points.length; i++) {
          final point = _scalePoint(
            Offset(
              contour.points[i].x.toDouble(),
              contour.points[i].y.toDouble(),
            ),
            size,
          );
          path.lineTo(point.dx, point.dy);
        }

        canvas.drawPath(path, paint);

        // Draw dots on contour points for better visibility
        final dotPaint = Paint()
          ..color = _getContourColor(type)
          ..style = PaintingStyle.fill;

        for (final point in contour.points) {
          final scaledPoint = _scalePoint(
            Offset(point.x.toDouble(), point.y.toDouble()),
            size,
          );
          canvas.drawCircle(scaledPoint, 1.5, dotPaint);
        }
      }
    });
  }

  /// Get color for different contour types
  Color _getContourColor(FaceContourType type) {
    switch (type) {
      case FaceContourType.face:
        return Colors.blue;
      case FaceContourType.leftEyebrowTop:
      case FaceContourType.leftEyebrowBottom:
      case FaceContourType.rightEyebrowTop:
      case FaceContourType.rightEyebrowBottom:
        return Colors.purple;
      case FaceContourType.leftEye:
      case FaceContourType.rightEye:
        return Colors.cyan;
      case FaceContourType.upperLipTop:
      case FaceContourType.upperLipBottom:
      case FaceContourType.lowerLipTop:
      case FaceContourType.lowerLipBottom:
        return Colors.pink;
      case FaceContourType.noseBridge:
      case FaceContourType.noseBottom:
        return Colors.orange;
      default:
        return Colors.blue;
    }
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

  /// Scale rectangle from camera coordinates to screen coordinates
  Rect _scaleRect(Rect rect, Size size) {
    final topLeft = _scalePoint(rect.topLeft, size);
    final bottomRight = _scalePoint(rect.bottomRight, size);

    return Rect.fromPoints(
      Offset(
        topLeft.dx < bottomRight.dx ? topLeft.dx : bottomRight.dx,
        topLeft.dy < bottomRight.dy ? topLeft.dy : bottomRight.dy,
      ),
      Offset(
        topLeft.dx > bottomRight.dx ? topLeft.dx : bottomRight.dx,
        topLeft.dy > bottomRight.dy ? topLeft.dy : bottomRight.dy,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant FaceLandmarksPainter oldDelegate) {
    return oldDelegate.faces != faces ||
        oldDelegate.cameraPreviewSize != cameraPreviewSize ||
        oldDelegate.screenSize != screenSize;
  }
}

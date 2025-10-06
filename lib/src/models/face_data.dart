import 'dart:ui';
import 'package:google_ml_kit/google_ml_kit.dart';

/// Represents face data detected during verification
class FaceData {
  /// Unique tracking ID for the face
  final int? trackingId;

  /// Bounding rectangle of the face
  final Rect boundingBox;

  /// Probability that the face is smiling (0.0 to 1.0)
  final double? smilingProbability;

  /// Probability that the left eye is open (0.0 to 1.0)
  final double? leftEyeOpenProbability;

  /// Probability that the right eye is open (0.0 to 1.0)
  final double? rightEyeOpenProbability;

  /// Head rotation around Y axis (yaw)
  final double? headEulerAngleY;

  /// Head rotation around Z axis (roll)
  final double? headEulerAngleZ;

  /// Timestamp when this face data was captured
  final DateTime timestamp;

  /// Original ML Kit Face object
  final Face? originalFace;

  const FaceData({
    this.trackingId,
    required this.boundingBox,
    this.smilingProbability,
    this.leftEyeOpenProbability,
    this.rightEyeOpenProbability,
    this.headEulerAngleY,
    this.headEulerAngleZ,
    required this.timestamp,
    this.originalFace,
  });

  /// Create FaceData from ML Kit Face object
  factory FaceData.fromFace(Face face) {
    return FaceData(
      trackingId: face.trackingId,
      boundingBox: face.boundingBox,
      smilingProbability: face.smilingProbability,
      leftEyeOpenProbability: face.leftEyeOpenProbability,
      rightEyeOpenProbability: face.rightEyeOpenProbability,
      headEulerAngleY: face.headEulerAngleY,
      headEulerAngleZ: face.headEulerAngleZ,
      timestamp: DateTime.now(),
      originalFace: face,
    );
  }

  /// Check if the face is smiling based on probability threshold
  bool isSmiling({double threshold = 0.5}) {
    // Reduced from 0.7 to 0.5
    return smilingProbability != null && smilingProbability! >= threshold;
  }

  /// Check if eyes are open based on probability threshold
  bool areEyesOpen({double threshold = 0.4}) {
    // Reduced from 0.5 to 0.4
    return (leftEyeOpenProbability != null &&
            leftEyeOpenProbability! >= threshold) ||
        (rightEyeOpenProbability != null &&
            rightEyeOpenProbability! >= threshold);
  }

  /// Check if eyes are closed based on probability threshold
  bool areEyesClosed({double threshold = 0.4}) {
    // Increased from 0.3 to 0.4
    return (leftEyeOpenProbability != null &&
            leftEyeOpenProbability! <= threshold) &&
        (rightEyeOpenProbability != null &&
            rightEyeOpenProbability! <= threshold);
  }

  /// Check if head pose is within acceptable range for verification
  bool hasGoodHeadPose({double maxYaw = 15.0, double maxRoll = 15.0}) {
    return (headEulerAngleY == null || headEulerAngleY!.abs() <= maxYaw) &&
        (headEulerAngleZ == null || headEulerAngleZ!.abs() <= maxRoll);
  }

  @override
  String toString() {
    return 'FaceData(id: $trackingId, '
        'smile: ${smilingProbability?.toStringAsFixed(2) ?? 'null'}, '
        'leftEye: ${leftEyeOpenProbability?.toStringAsFixed(2) ?? 'null'}, '
        'rightEye: ${rightEyeOpenProbability?.toStringAsFixed(2) ?? 'null'}, '
        'yaw: ${headEulerAngleY?.toStringAsFixed(1) ?? 'null'}, '
        'roll: ${headEulerAngleZ?.toStringAsFixed(1) ?? 'null'}, '
        'bbox: ${boundingBox.width.toInt()}x${boundingBox.height.toInt()})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FaceData &&
        other.trackingId == trackingId &&
        other.boundingBox == boundingBox &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return trackingId.hashCode ^ boundingBox.hashCode ^ timestamp.hashCode;
  }
}

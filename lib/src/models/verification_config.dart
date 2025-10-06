/// Enumeration of verification steps
enum VerificationStep {
  faceDetection,
  smileDetection,
  eyeCloseDetection,
  eyeOpenDetection,
  completed,
}

/// Configuration for face verification process
class FaceVerificationConfig {
  /// Timeout for each verification step in seconds
  final int timeoutPerStep;

  /// Minimum confidence for smile detection
  final double smileThreshold;

  /// Minimum confidence for eye open detection
  final double eyeOpenThreshold;

  /// Maximum confidence for eye closed detection
  final double eyeClosedThreshold;

  /// Maximum allowed head rotation (yaw/roll) in degrees
  final double maxHeadRotation;

  /// Whether to save face images automatically
  final bool saveImages;

  /// Directory to save face images (null for default)
  final String? saveDirectory;

  /// Image quality (0.0 to 1.0)
  final double imageQuality;

  /// Number of face images to capture
  final int numberOfImages;

  const FaceVerificationConfig({
    this.timeoutPerStep = 5,
    this.smileThreshold = 0.7,
    this.eyeOpenThreshold = 0.5,
    this.eyeClosedThreshold = 0.3,
    this.maxHeadRotation = 15.0,
    this.saveImages = true,
    this.saveDirectory,
    this.imageQuality = 0.9,
    this.numberOfImages = 3,
  });

  /// Create a copy with modified parameters
  FaceVerificationConfig copyWith({
    int? timeoutPerStep,
    double? smileThreshold,
    double? eyeOpenThreshold,
    double? eyeClosedThreshold,
    double? maxHeadRotation,
    bool? saveImages,
    String? saveDirectory,
    double? imageQuality,
    int? numberOfImages,
  }) {
    return FaceVerificationConfig(
      timeoutPerStep: timeoutPerStep ?? this.timeoutPerStep,
      smileThreshold: smileThreshold ?? this.smileThreshold,
      eyeOpenThreshold: eyeOpenThreshold ?? this.eyeOpenThreshold,
      eyeClosedThreshold: eyeClosedThreshold ?? this.eyeClosedThreshold,
      maxHeadRotation: maxHeadRotation ?? this.maxHeadRotation,
      saveImages: saveImages ?? this.saveImages,
      saveDirectory: saveDirectory ?? this.saveDirectory,
      imageQuality: imageQuality ?? this.imageQuality,
      numberOfImages: numberOfImages ?? this.numberOfImages,
    );
  }
}

import 'face_data.dart';

/// Result of the face verification process
class VerificationResult {
  /// Whether the verification was successful
  final bool success;

  /// List of face image paths that were captured
  final List<String> faceImagePaths;

  /// List of face data detected during verification
  final List<FaceData> faceData;

  /// Error message if verification failed
  final String? errorMessage;

  /// Total time taken for verification
  final Duration? verificationDuration;

  const VerificationResult({
    required this.success,
    required this.faceImagePaths,
    required this.faceData,
    this.errorMessage,
    this.verificationDuration,
  });

  /// Create a successful verification result
  factory VerificationResult.success({
    required List<String> faceImagePaths,
    required List<FaceData> faceData,
    Duration? verificationDuration,
  }) {
    return VerificationResult(
      success: true,
      faceImagePaths: faceImagePaths,
      faceData: faceData,
      verificationDuration: verificationDuration,
    );
  }

  /// Create a failed verification result
  factory VerificationResult.failure({
    required String errorMessage,
    Duration? verificationDuration,
  }) {
    return VerificationResult(
      success: false,
      faceImagePaths: [],
      faceData: [],
      errorMessage: errorMessage,
      verificationDuration: verificationDuration,
    );
  }

  @override
  String toString() {
    return 'VerificationResult(success: $success, faceImages: ${faceImagePaths.length}, faceData: ${faceData.length})';
  }
}

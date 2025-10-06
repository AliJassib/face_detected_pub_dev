// Plugin interface
import 'face_detected_platform_interface.dart';

// Main face verification functionality
export 'src/face_verification.dart';
export 'src/models/face_data.dart';
export 'src/models/verification_result.dart';
export 'src/models/verification_config.dart';
export 'src/widgets/face_verification_widget.dart';

/// Main plugin class for backward compatibility
class FaceDetected {
  Future<String?> getPlatformVersion() {
    return FaceDetectedPlatform.instance.getPlatformVersion();
  }
}

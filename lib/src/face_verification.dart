import 'package:flutter/material.dart';
import 'widgets/face_verification_widget.dart';
import 'models/verification_config.dart';
import 'models/verification_result.dart';
import 'models/face_data.dart';

/// Export all the models and enums for public use
export 'models/verification_config.dart';
export 'models/verification_result.dart';
export 'models/face_data.dart';
export 'widgets/face_verification_widget.dart';

/// Main class for Face Verification package
class FaceVerification {
  /// Create a face verification widget
  static Widget createWidget({
    Key? key,
    FaceVerificationConfig? config,
    int timeoutPerStep = 5,
    required Function(VerificationResult) onVerificationComplete,
    Function(String)? onError,
    Function(VerificationStep)? onStepChanged,
    Function(FaceData)? onFaceDetected,
    Widget Function(BuildContext context)? customOverlay,
    Widget Function(BuildContext context, String instruction)?
    customInstructions,
    Color primaryColor = Colors.blue,
    Color backgroundColor = Colors.black,
    Color textColor = Colors.white,
    bool showDebugInfo = false,
    bool showFaceLandmarks = true,
  }) {
    return FaceVerificationWidget(
      key: key,
      config: config,
      timeoutPerStep: timeoutPerStep,
      onVerificationComplete: onVerificationComplete,
      onError: onError,
      onStepChanged: onStepChanged,
      onFaceDetected: onFaceDetected,
      customOverlay: customOverlay,
      customInstructions: customInstructions,
      primaryColor: primaryColor,
      backgroundColor: backgroundColor,
      textColor: textColor,
      showDebugInfo: showDebugInfo,
      showFaceLandmarks: showFaceLandmarks,
    );
  }

  /// Show face verification as a full screen page
  static Future<VerificationResult?> showVerificationPage(
    BuildContext context, {
    FaceVerificationConfig? config,
    int timeoutPerStep = 5,
    Function(String)? onError,
    Function(VerificationStep)? onStepChanged,
    Function(FaceData)? onFaceDetected,
    Widget Function(BuildContext context)? customOverlay,
    Widget Function(BuildContext context, String instruction)?
    customInstructions,
    Color primaryColor = Colors.blue,
    Color backgroundColor = Colors.black,
    Color textColor = Colors.white,
    bool showDebugInfo = false,
    bool showFaceLandmarks = true,
  }) async {
    VerificationResult? result;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FaceVerificationWidget(
          config: config,
          timeoutPerStep: timeoutPerStep,
          onVerificationComplete: (verificationResult) {
            result = verificationResult;
            Navigator.of(context).pop();
          },
          onError: onError,
          onStepChanged: onStepChanged,
          onFaceDetected: onFaceDetected,
          customOverlay: customOverlay,
          customInstructions: customInstructions,
          primaryColor: primaryColor,
          backgroundColor: backgroundColor,
          textColor: textColor,
          showDebugInfo: showDebugInfo,
          showFaceLandmarks: showFaceLandmarks,
        ),
      ),
    );

    return result;
  }

  /// Show face verification as a modal bottom sheet
  static Future<VerificationResult?> showVerificationModal(
    BuildContext context, {
    FaceVerificationConfig? config,
    int timeoutPerStep = 5,
    Function(String)? onError,
    Function(VerificationStep)? onStepChanged,
    Function(FaceData)? onFaceDetected,
    Widget Function(BuildContext context)? customOverlay,
    Widget Function(BuildContext context, String instruction)?
    customInstructions,
    Color primaryColor = Colors.blue,
    Color backgroundColor = Colors.black,
    Color textColor = Colors.white,
    bool showDebugInfo = false,
    bool showFaceLandmarks = true,
    double height = 0.9,
  }) async {
    VerificationResult? result;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * height,
        child: FaceVerificationWidget(
          config: config,
          timeoutPerStep: timeoutPerStep,
          onVerificationComplete: (verificationResult) {
            result = verificationResult;
            Navigator.of(context).pop();
          },
          onError: onError,
          onStepChanged: onStepChanged,
          onFaceDetected: onFaceDetected,
          customOverlay: customOverlay,
          customInstructions: customInstructions,
          primaryColor: primaryColor,
          backgroundColor: backgroundColor,
          textColor: textColor,
          showDebugInfo: showDebugInfo,
          showFaceLandmarks: showFaceLandmarks,
        ),
      ),
    );

    return result;
  }
}

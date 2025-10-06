import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/face_verification_controller.dart';
import '../models/face_data.dart';
import '../models/verification_config.dart';
import '../models/verification_result.dart';

/// Widget for face verification with customizable UI
class FaceVerificationWidget extends StatefulWidget {
  /// Configuration for verification process
  final FaceVerificationConfig? config;

  /// Timeout per verification step in seconds
  final int timeoutPerStep;

  /// Callback when verification is complete
  final Function(VerificationResult) onVerificationComplete;

  /// Callback when an error occurs
  final Function(String)? onError;

  /// Callback when verification step changes
  final Function(VerificationStep)? onStepChanged;

  /// Callback when a face is detected
  final Function(FaceData)? onFaceDetected;

  /// Custom overlay widget
  final Widget Function(BuildContext context)? customOverlay;

  /// Custom instruction widget
  final Widget Function(BuildContext context, String instruction)? customInstructions;

  /// Theme colors
  final Color primaryColor;
  final Color backgroundColor;
  final Color textColor;

  /// Show debug information
  final bool showDebugInfo;

  const FaceVerificationWidget({
    Key? key,
    this.config,
    this.timeoutPerStep = 5,
    required this.onVerificationComplete,
    this.onError,
    this.onStepChanged,
    this.onFaceDetected,
    this.customOverlay,
    this.customInstructions,
    this.primaryColor = Colors.blue,
    this.backgroundColor = Colors.black,
    this.textColor = Colors.white,
    this.showDebugInfo = false,
  }) : super(key: key);

  @override
  State<FaceVerificationWidget> createState() => _FaceVerificationWidgetState();
}

class _FaceVerificationWidgetState extends State<FaceVerificationWidget> {
  late FaceVerificationController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(FaceVerificationController());
    _initializeVerification();
  }

  @override
  void dispose() {
    Get.delete<FaceVerificationController>();
    super.dispose();
  }

  Future<void> _initializeVerification() async {
    final config = widget.config ?? FaceVerificationConfig(timeoutPerStep: widget.timeoutPerStep);

    await controller.initialize(
      verificationConfig: config,
      onComplete: widget.onVerificationComplete,
      onErrorCallback: widget.onError,
      onStepChange: widget.onStepChanged,
      onFaceDetection: widget.onFaceDetected,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.backgroundColor,
      body: Obx(() {
        if (!controller.isCameraInitialized.value) {
          return _buildLoadingWidget();
        }

        return Stack(children: [_buildCameraPreview(), _buildOverlay(), if (widget.showDebugInfo) _buildDebugInfo()]);
      }),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(widget.primaryColor)),
          const SizedBox(height: 16),
          Text('Initializing camera...', style: TextStyle(color: widget.textColor, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    final cameraController = controller.cameraController;
    if (cameraController == null || !cameraController.value.isInitialized) {
      return Container();
    }

    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(width: cameraController.value.previewSize!.height, height: cameraController.value.previewSize!.width, child: CameraPreview(cameraController)),
      ),
    );
  }

  Widget _buildOverlay() {
    if (widget.customOverlay != null) {
      return widget.customOverlay!(context);
    }

    return Positioned.fill(
      child: Column(
        children: [
          _buildHeader(),

          // Expanded(
          //   child: _buildFaceGuide(),
          // ),
          Spacer(),
          _buildInstructions(),
          _buildControls(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.close, color: widget.textColor),
              onPressed: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: Text(
                'Face Verification',
                style: TextStyle(color: widget.textColor, fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 48), // Balance the close button
          ],
        ),
      ),
    );
  }

  Widget _buildFaceGuide() {
    return Center(
      child: Obx(() {
        final hasDetectedFace = controller.detectedFaces.isNotEmpty;
        final isStepCompleted = controller.isStepCompleted.value;
        final isTransitioning = controller.isTransitioning.value;

        // Determine circle color and animation based on state
        Color circleColor;
        String displayText;
        double scale = 1.0;

        if (isStepCompleted) {
          circleColor = Colors.green;
          displayText = '✓';
          scale = 1.2; // Scale up for success animation
        } else if (hasDetectedFace) {
          circleColor = Colors.green;
          displayText = '✓';
        } else {
          circleColor = widget.primaryColor;
          displayText = '👤';
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          transform: Matrix4.identity()..scale(scale),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 250,
            height: 320,
            decoration: BoxDecoration(
              border: Border.all(color: circleColor, width: isStepCompleted ? 6 : 4),
              borderRadius: BorderRadius.circular(125),
              boxShadow: isStepCompleted ? [BoxShadow(color: Colors.green.withOpacity(0.5), blurRadius: 20, spreadRadius: 5)] : null,
            ),
            child: Center(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(fontSize: isStepCompleted ? 60 : 48, color: circleColor),
                child: Text(displayText),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildInstructions() {
    return Obx(() {
      final instruction = controller.statusMessage.value;
      final isStepCompleted = controller.isStepCompleted.value;
      final successMessage = controller.successMessage.value;

      if (widget.customInstructions != null) {
        return widget.customInstructions!(context, instruction);
      }

      return AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: isStepCompleted ? Colors.green.withOpacity(0.8) : Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(25),
          boxShadow: isStepCompleted ? [BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 15, spreadRadius: 3)] : null,
        ),
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(color: widget.textColor, fontSize: isStepCompleted ? 20 : 18, fontWeight: isStepCompleted ? FontWeight.bold : FontWeight.w500),
              child: Text(instruction, textAlign: TextAlign.center),
            ),
            if (isStepCompleted && successMessage.isNotEmpty) ...[
              const SizedBox(height: 8),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: 1.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Success!',
                      style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
            // const SizedBox(height: 8),
            // _buildStepIndicator(),
          ],
        ),
      );
    });
  }

  Widget _buildStepIndicator() {
    return Obx(() {
      final currentStep = controller.currentStep.value;
      final steps = VerificationStep.values.take(4).toList(); // Exclude completed

      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: steps.map((step) {
          final isActive = step.index <= currentStep.index;
          final isCurrent = step == currentStep;

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 12,
            height: 12,
            decoration: BoxDecoration(shape: BoxShape.circle, color: isActive ? (isCurrent ? widget.primaryColor : Colors.green) : widget.textColor.withOpacity(0.3)),
          );
        }).toList(),
      );
    });
  }

  Widget _buildControls() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Obx(() {
              if (controller.isVerificationComplete.value || controller.errorMessage.value.isNotEmpty) {
                return ElevatedButton(
                  onPressed: () => controller.restart(),
                  style: ElevatedButton.styleFrom(backgroundColor: widget.primaryColor, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                  child: const Text('Try Again'),
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDebugInfo() {
    return Positioned(
      top: 100,
      left: 16,
      child: Obx(() {
        final faces = controller.detectedFaces;
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), borderRadius: BorderRadius.circular(8)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Debug Info',
                style: TextStyle(color: widget.textColor, fontWeight: FontWeight.bold),
              ),
              Text('Step: ${controller.currentStep.value.name}', style: TextStyle(color: widget.textColor)),
              Text('Faces: ${faces.length}', style: TextStyle(color: widget.textColor)),
              if (faces.isNotEmpty) ...[
                Text('Smile: ${faces.first.smilingProbability?.toStringAsFixed(2) ?? 'N/A'}', style: TextStyle(color: widget.textColor)),
                Text(
                  'Eyes: L${faces.first.leftEyeOpenProbability?.toStringAsFixed(2) ?? 'N/A'} '
                  'R${faces.first.rightEyeOpenProbability?.toStringAsFixed(2) ?? 'N/A'}',
                  style: TextStyle(color: widget.textColor),
                ),
              ],
            ],
          ),
        );
      }),
    );
  }
}

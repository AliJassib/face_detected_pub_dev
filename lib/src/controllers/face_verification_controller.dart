import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:get/get.dart';
import '../models/face_data.dart';
import '../models/verification_result.dart';
import '../models/verification_config.dart';
import '../services/face_detection_service.dart';
import '../utils/image_utils.dart';

/// Controller for managing face verification process
class FaceVerificationController extends GetxController {
  // Camera
  CameraController? _cameraController;
  final RxBool isCameraInitialized = false.obs;
  final RxBool isProcessing = false.obs;

  // Face Detection Service
  final FaceDetectionService _faceDetectionService = FaceDetectionService();

  // Verification State
  final Rx<VerificationStep> currentStep = VerificationStep.faceDetection.obs;
  final RxList<FaceData> detectedFaces = <FaceData>[].obs;
  final RxList<String> capturedImagePaths = <String>[].obs;
  final RxString statusMessage = 'Initializing camera...'.obs;
  final RxBool isVerificationComplete = false.obs;
  final RxString errorMessage = ''.obs;

  // Step transition animation states
  final RxBool isStepCompleted = false.obs;
  final RxBool isTransitioning = false.obs;
  final RxString successMessage = ''.obs;

  // Face mesh animation states
  final RxBool hasShownAnimation = false.obs;
  final RxBool showFaceMesh = false.obs;
  final RxBool showVerificationMessage = false.obs;
  final RxString verificationMessage = ''.obs;

  // Configuration
  late FaceVerificationConfig config;

  // Timers
  Timer? _stepTimer;
  DateTime? _stepStartTime;

  // Callbacks
  Function(VerificationResult)? onVerificationComplete;
  Function(String)? onError;
  Function(VerificationStep)? onStepChanged;
  Function(FaceData)? onFaceDetected;

  @override
  void onInit() {
    super.onInit();
    config = const FaceVerificationConfig();
  }

  @override
  void onClose() {
    _dispose();
    super.onClose();
  }

  /// Initialize the verification process
  Future<void> initialize({
    FaceVerificationConfig? verificationConfig,
    Function(VerificationResult)? onComplete,
    Function(String)? onErrorCallback,
    Function(VerificationStep)? onStepChange,
    Function(FaceData)? onFaceDetection,
  }) async {
    try {
      config = verificationConfig ?? const FaceVerificationConfig();
      onVerificationComplete = onComplete;
      onError = onErrorCallback;
      onStepChanged = onStepChange;
      onFaceDetected = onFaceDetection;

      await _initializeCamera();
      await _faceDetectionService.initialize();

      _startVerification();
    } catch (e) {
      _handleError('Failed to initialize: $e');
    }
  }

  /// Initialize camera
  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      throw Exception('No cameras available');
    }

    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    // Use higher resolution for better face detection
    _cameraController = CameraController(
      frontCamera,
      ResolutionPreset.high, // Changed from medium to high for better detection
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.yuv420
          : ImageFormatGroup.bgra8888, // Platform specific format
    );

    await _cameraController!.initialize();
    isCameraInitialized.value = true;

    // Add longer delay to ensure camera is fully ready
    await Future.delayed(const Duration(milliseconds: 1000));

    // Start image stream for face detection
    _cameraController!.startImageStream(_processCameraImage);

    print(
      'Camera initialized: ${frontCamera.name}, Resolution: high, Format: ${Platform.isAndroid ? 'YUV420' : 'BGRA8888'}',
    );
  }

  /// Start the verification process
  void _startVerification() {
    currentStep.value = VerificationStep.faceDetection;
    statusMessage.value = 'Please look at the camera';
    _startStepTimer();
    onStepChanged?.call(currentStep.value);
  }

  /// Process camera image for face detection
  void _processCameraImage(CameraImage image) async {
    if (isProcessing.value || isVerificationComplete.value) return;

    // Validate camera image
    if (image.planes.isEmpty || image.width <= 0 || image.height <= 0) {
      print(
        'Invalid camera image: planes=${image.planes.length}, size=${image.width}x${image.height}',
      );
      return;
    }

    isProcessing.value = true;

    try {
      print(
        'Processing image: ${image.width}x${image.height}, format: ${image.format.group}, planes: ${image.planes.length}',
      );

      final faces = await _faceDetectionService.detectFacesFromCameraImage(
        image,
      );
      detectedFaces.value = faces;

      print('Detected ${faces.length} faces');

      if (faces.isNotEmpty) {
        final face = faces.first;
        print('Face detected: ${face.toString()}');

        onFaceDetected?.call(face);
        await _handleDetectedFace(face, image);
      } else {
        _updateStatusForNoFace();
      }
    } catch (e) {
      print('Error processing camera image: $e');
      errorMessage.value = 'Face detection error: $e';
    } finally {
      isProcessing.value = false;
    }
  }

  /// Handle detected face based on current step
  Future<void> _handleDetectedFace(FaceData face, CameraImage image) async {
    if (isTransitioning.value || isStepCompleted.value) return;

    if (!face.hasGoodHeadPose(
      maxYaw: config.maxHeadRotation,
      maxRoll: config.maxHeadRotation,
    )) {
      statusMessage.value = 'Please face the camera directly';
      return;
    }

    switch (currentStep.value) {
      case VerificationStep.faceDetection:
        statusMessage.value = 'Face detected! Please smile';
        await _showSuccessAndTransition(
          'Face detected successfully!',
          VerificationStep.smileDetection,
        );
        break;

      case VerificationStep.smileDetection:
        if (face.isSmiling(threshold: config.smileThreshold)) {
          await _captureImage(image, face);
          await _showSuccessAndTransition(
            'Perfect smile!',
            VerificationStep.eyeCloseDetection,
          );
        } else {
          statusMessage.value = 'Please smile for the camera';
        }
        break;

      case VerificationStep.eyeCloseDetection:
        if (face.areEyesClosed(threshold: config.eyeClosedThreshold)) {
          await _captureImage(image, face);
          await _showSuccessAndTransition(
            'Eyes closed perfectly!',
            VerificationStep.eyeOpenDetection,
          );
        } else {
          statusMessage.value = 'Please close your eyes';
        }
        break;

      case VerificationStep.eyeOpenDetection:
        if (face.areEyesOpen(threshold: config.eyeOpenThreshold)) {
          await _captureImage(image, face);
          await _showSuccessAndTransition(
            'Verification complete!',
            VerificationStep.completed,
          );
        } else {
          statusMessage.value = 'Please open your eyes wide';
        }
        break;

      case VerificationStep.completed:
        _completeVerification();
        break;
    }
  }

  /// Update status message when no face is detected
  void _updateStatusForNoFace() {
    switch (currentStep.value) {
      case VerificationStep.faceDetection:
        statusMessage.value = 'Please position your face in the camera';
        break;
      case VerificationStep.smileDetection:
        statusMessage.value = 'Face not detected. Please smile for the camera';
        break;
      case VerificationStep.eyeCloseDetection:
        statusMessage.value = 'Face not detected. Please close your eyes';
        break;
      case VerificationStep.eyeOpenDetection:
        statusMessage.value = 'Face not detected. Please open your eyes wide';
        break;
      default:
        statusMessage.value = 'Face not detected. Please look at the camera';
        break;
    }
  }

  /// Move to the next verification step
  void _moveToNextStep(VerificationStep nextStep) {
    _cancelStepTimer();
    currentStep.value = nextStep;
    onStepChanged?.call(nextStep);

    if (nextStep == VerificationStep.completed) {
      _completeVerification();
    } else {
      _startStepTimer();
    }
  }

  /// Start timer for current step
  void _startStepTimer() {
    _stepStartTime = DateTime.now();
    _stepTimer = Timer(Duration(seconds: config.timeoutPerStep), () {
      _handleStepTimeout();
    });
  }

  /// Cancel step timer
  void _cancelStepTimer() {
    _stepTimer?.cancel();
    _stepTimer = null;
  }

  /// Handle step timeout
  void _handleStepTimeout() {
    _handleError('Verification timeout. Please try again.');
  }

  /// Capture image from camera
  Future<void> _captureImage(CameraImage cameraImage, FaceData face) async {
    try {
      if (!config.saveImages) return;

      final image = ImageUtils.convertCameraImageToImage(cameraImage);
      if (image == null) return;

      final croppedFace = ImageUtils.cropFace(image, face);
      if (croppedFace == null) return;

      final resizedImage = ImageUtils.resizeImage(croppedFace, maxSize: 512);

      final imagePath = await ImageUtils.saveImageToFile(
        resizedImage,
        directory: config.saveDirectory,
        quality: (config.imageQuality * 100).toInt(),
      );

      if (imagePath != null) {
        capturedImagePaths.add(imagePath);
      }
    } catch (e) {
      print('Error capturing image: $e');
    }
  }

  /// Complete verification process
  void _completeVerification() {
    isVerificationComplete.value = true;
    _cancelStepTimer();

    final verificationDuration = _stepStartTime != null
        ? DateTime.now().difference(_stepStartTime!)
        : null;

    final result = VerificationResult.success(
      faceImagePaths: capturedImagePaths.toList(),
      faceData: detectedFaces.toList(),
      verificationDuration: verificationDuration,
    );

    onVerificationComplete?.call(result);
  }

  /// Handle error during verification
  void _handleError(String error) {
    errorMessage.value = error;
    _cancelStepTimer();

    final verificationDuration = _stepStartTime != null
        ? DateTime.now().difference(_stepStartTime!)
        : null;

    final result = VerificationResult.failure(
      errorMessage: error,
      verificationDuration: verificationDuration,
    );

    onError?.call(error);
    onVerificationComplete?.call(result);
  }

  /// Restart verification process
  void restart() {
    currentStep.value = VerificationStep.faceDetection;
    detectedFaces.clear();
    capturedImagePaths.clear();
    isVerificationComplete.value = false;
    errorMessage.value = '';
    _startVerification();
  }

  /// Dispose resources
  void _dispose() {
    _cancelStepTimer();
    _cameraController?.stopImageStream();
    _cameraController?.dispose();
    _faceDetectionService.dispose();
  }

  /// Get camera controller
  CameraController? get cameraController => _cameraController;

  /// Show success animation and transition to next step
  Future<void> _showSuccessAndTransition(
    String successMsg,
    VerificationStep nextStep,
  ) async {
    // Stop processing temporarily
    isStepCompleted.value = true;
    isTransitioning.value = true;

    // Show success message
    successMessage.value = successMsg;
    statusMessage.value = successMsg;

    // Wait for success animation (1.5 seconds)
    await Future.delayed(const Duration(milliseconds: 1500));

    // Reset states
    isStepCompleted.value = false;
    successMessage.value = '';

    // Move to next step
    _moveToNextStep(nextStep);

    // Set new step message with delay for smooth transition
    await Future.delayed(const Duration(milliseconds: 300));
    _setMessageForStep(nextStep);

    // Allow processing again
    isTransitioning.value = false;
  }

  /// Set appropriate message for each step
  void _setMessageForStep(VerificationStep step) {
    switch (step) {
      case VerificationStep.faceDetection:
        statusMessage.value = 'Please look at the camera';
        break;
      case VerificationStep.smileDetection:
        statusMessage.value = 'Now please smile for the camera';
        break;
      case VerificationStep.eyeCloseDetection:
        statusMessage.value = 'Now please close your eyes';
        break;
      case VerificationStep.eyeOpenDetection:
        statusMessage.value = 'Now please open your eyes wide';
        break;
      case VerificationStep.completed:
        statusMessage.value = 'Verification completed successfully!';
        break;
    }
  }
}

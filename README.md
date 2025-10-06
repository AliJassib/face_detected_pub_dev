# Face Verification

A comprehensive Flutter package that provides intelligent face verification capabilities with multi-step authentication using facial expressions and gestures. This package combines advanced machine learning face detection with user-friendly verification workflows, making it perfect for secure authentication, identity verification, and interactive camera applications.

## Features

- ✅ **Face detection** using Google ML Kit
- 😊 **Smile detection** verification with configurable confidence threshold
- 👁️ **Eye closure/opening** verification for liveness detection
- 📸 **Automatic face cropping** with multiple sizes and quality options
- ⏰ **Configurable timeout** per verification step
- 🎨 **Customizable UI components** with theme support
- 📱 **High-quality face images** optimized for ML/AI applications
- 🔄 **Multiple integration options** (full screen, modal, custom widget)
- 🛡️ **Permission handling** for camera and storage
- 💾 **Automatic image saving** to device storage or gallery

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  face_detected: ^0.0.1
```

Then run:
```bash
flutter pub get
```

## Platform Setup

### Android
Add the following permissions to your `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

### iOS
Add the following to your `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access for face verification</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs photo library access to save verification images</string>
```

## Usage

### Basic Usage

```dart
import 'package:face_detected/face_detected.dart';

// Show face verification as a full screen page
final result = await FaceVerification.showVerificationPage(
  context,
  timeoutPerStep: 5, // 5 seconds per step
  onVerificationComplete: (VerificationResult result) {
    if (result.success) {
      // Verification successful
      print('Verification completed!');
      print('Captured ${result.faceImagePaths.length} images');
      
      // Access face data
      for (FaceData face in result.faceData) {
        print('Face ID: ${face.trackingId}');
        print('Smile confidence: ${face.smilingProbability}');
        print('Eyes open: ${face.areEyesOpen()}');
      }
    } else {
      // Verification failed
      print('Verification failed: ${result.errorMessage}');
    }
  },
  onError: (String error) {
    print('Verification error: $error');
  },
);
```

### Advanced Configuration

```dart
// Create custom configuration
final config = FaceVerificationConfig(
  timeoutPerStep: 10,        // 10 seconds per step
  smileThreshold: 0.8,       // 80% confidence for smile
  eyeOpenThreshold: 0.6,     // 60% confidence for eyes open
  eyeClosedThreshold: 0.2,   // 20% confidence for eyes closed
  maxHeadRotation: 15.0,     // Max 15 degrees head rotation
  saveImages: true,          // Save captured images
  imageQuality: 0.9,         // 90% image quality
  numberOfImages: 3,         // Capture 3 images
);

// Use custom configuration
final result = await FaceVerification.showVerificationPage(
  context,
  config: config,
  primaryColor: Colors.green,
  backgroundColor: Colors.black87,
  showDebugInfo: true,
  onStepChanged: (step) {
    print('Current step: ${step.name}');
  },
  onFaceDetected: (faceData) {
    print('Face detected: ${faceData.toString()}');
  },
);
```

### Modal Integration

```dart
// Show as a modal bottom sheet
final result = await FaceVerification.showVerificationModal(
  context,
  height: 0.8, // 80% of screen height
  timeoutPerStep: 8,
);
```

### Custom Widget Integration

```dart
// Use as a custom widget in your app
Widget build(BuildContext context) {
  return Scaffold(
    body: FaceVerification.createWidget(
      onVerificationComplete: (result) {
        // Handle result
      },
      customInstructions: (context, instruction) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Text(
            instruction,
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        );
      },
    ),
  );
}
```

## Verification Steps

The face verification process consists of these steps:

1. **Face Detection** - Detects and tracks a face in the camera
2. **Smile Detection** - Asks user to smile and verifies the smile
3. **Eyes Open Detection** - Asks user to open eyes wide
4. **Eyes Closed Detection** - Asks user to close eyes
5. **Completion** - Verification completed successfully

Each step has a configurable timeout and confidence threshold.

## Models

### VerificationResult

```dart
class VerificationResult {
  final bool success;                    // Whether verification succeeded
  final List<String> faceImagePaths;    // Paths to captured face images
  final List<FaceData> faceData;        // Face detection data
  final String? errorMessage;           // Error message if failed
  final Duration? verificationDuration; // Time taken for verification
}
```

### FaceData

```dart
class FaceData {
  final int? trackingId;                    // Unique face tracking ID
  final Rect boundingBox;                   // Face bounding rectangle
  final double? smilingProbability;         // Smile confidence (0.0-1.0)
  final double? leftEyeOpenProbability;     // Left eye open confidence
  final double? rightEyeOpenProbability;    // Right eye open confidence
  final double? headEulerAngleY;            // Head yaw rotation
  final double? headEulerAngleZ;            // Head roll rotation
  final DateTime timestamp;                 // When face was detected
  
  // Helper methods
  bool isSmiling({double threshold = 0.7});
  bool areEyesOpen({double threshold = 0.5});
  bool areEyesClosed({double threshold = 0.3});
  bool hasGoodHeadPose({double maxYaw = 15.0, double maxRoll = 15.0});
}
```

### FaceVerificationConfig

```dart
class FaceVerificationConfig {
  final int timeoutPerStep;          // Timeout for each step (seconds)
  final double smileThreshold;       // Smile confidence threshold
  final double eyeOpenThreshold;     // Eye open confidence threshold
  final double eyeClosedThreshold;   // Eye closed confidence threshold
  final double maxHeadRotation;      // Max allowed head rotation (degrees)
  final bool saveImages;             // Whether to save captured images
  final String? saveDirectory;       // Custom save directory
  final double imageQuality;         // Image quality (0.0-1.0)
  final int numberOfImages;          // Number of images to capture
}
```

## Customization

### UI Customization

```dart
FaceVerification.showVerificationPage(
  context,
  primaryColor: Colors.purple,           // Primary theme color
  backgroundColor: Colors.black,         // Background color
  textColor: Colors.white,              // Text color
  customOverlay: (context) {            // Custom overlay widget
    return YourCustomOverlay();
  },
  customInstructions: (context, instruction) {  // Custom instructions
    return YourCustomInstructionWidget(instruction);
  },
);
```

### Callbacks

```dart
FaceVerification.showVerificationPage(
  context,
  onStepChanged: (VerificationStep step) {
    // Called when verification step changes
    print('Step: ${step.name}');
  },
  onFaceDetected: (FaceData faceData) {
    // Called when a face is detected
    print('Face: ${faceData.toString()}');
  },
  onError: (String error) {
    // Called when an error occurs
    print('Error: $error');
  },
);
```

## Example

Run the example app to see the face verification in action:

```bash
cd example
flutter run
```

The example demonstrates:
- Basic face verification
- Modal integration
- Custom configuration
- Result handling
- Error handling

## Requirements

- Flutter 3.3.0 or higher
- Dart 3.9.2 or higher
- Camera permission
- Storage permission (for saving images)

## Dependencies

This package uses:
- `google_ml_kit` for face detection
- `camera` for camera access
- `get` for state management
- `permission_handler` for permissions
- `path_provider` for file storage
- `image_gallery_saver_plus` for gallery saving
- `image` for image processing

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

If you find this package helpful, please give it a ⭐ on GitHub!

## API Reference

### SmileyVerificationWidget

| Parameter                | Type                           | Description                                   |
|--------------------------|--------------------------------|-----------------------------------------------|
| `onVerificationComplete` | `Function(VerificationResult)` | Called when verification completes            |
| `onVerificationStarted`  | `VoidCallback?`                | Called when verification starts               |
| `onStepChanged`          | `Function(String)?`            | Called when verification step changes         |
| `onError`                | `Function(String)?`            | Called when an error occurs                   |
| `timeoutPerStep`         | `int`                          | Timeout in seconds for each step (default: 3) |
| `enableSnowEffect`       | `bool`                         | Enable snow animation effect                  |
| `customStartButton`      | `Widget?`                      | Custom start button widget                    |

### VerificationResult

| Property         | Type             | Description                    |
|------------------|------------------|--------------------------------|
| `success`        | `bool`           | Whether verification succeeded |
| `faceImagePaths` | `List<String>`   | Paths to captured face images  |
| `errorMessage`   | `String?`        | Error message if failed        |
| `faceData`       | `List<FaceData>` | Detailed face data             |

## License

MIT License
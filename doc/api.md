# Face Detected API Documentation

## Table of Contents

- [FaceVerification](#faceverification)
- [FaceVerificationConfig](#faceverificationconfig)
- [VerificationResult](#verificationresult)
- [FaceData](#facedata)
- [VerificationStep](#verificationstep)
- [Enums](#enums)
- [Callbacks](#callbacks)

## FaceVerification

The main class for integrating face verification functionality.

### Static Methods

#### `createWidget`

Creates a face verification widget that can be embedded in your app.

```dart
static Widget createWidget({
  Key? key,
  FaceVerificationConfig? config,
  int timeoutPerStep = 5,
  required Function(VerificationResult) onVerificationComplete,
  Function(String)? onError,
  Function(VerificationStep)? onStepChanged,
  Function(FaceData)? onFaceDetected,
  Widget Function(BuildContext context)? customOverlay,
  Widget Function(BuildContext context, String instruction)? customInstructions,
  Color primaryColor = Colors.blue,
  Color backgroundColor = Colors.black,
  Color textColor = Colors.white,
  bool showDebugInfo = false,
})
```

**Parameters:**
- `key`: Widget key
- `config`: Verification configuration (optional)
- `timeoutPerStep`: Timeout for each step in seconds (default: 5)
- `onVerificationComplete`: Required callback when verification completes
- `onError`: Optional error callback
- `onStepChanged`: Optional callback when step changes
- `onFaceDetected`: Optional callback when face is detected
- `customOverlay`: Optional custom overlay widget
- `customInstructions`: Optional custom instructions widget
- `primaryColor`: Primary theme color (default: Colors.blue)
- `backgroundColor`: Background color (default: Colors.black)
- `textColor`: Text color (default: Colors.white)
- `showDebugInfo`: Enable debug information (default: false)

#### `showVerificationPage`

Shows face verification as a full-screen page.

```dart
static Future<VerificationResult?> showVerificationPage(
  BuildContext context, {
  FaceVerificationConfig? config,
  int timeoutPerStep = 5,
  Function(String)? onError,
  Function(VerificationStep)? onStepChanged,
  Function(FaceData)? onFaceDetected,
  Widget Function(BuildContext context)? customOverlay,
  Widget Function(BuildContext context, String instruction)? customInstructions,
  Color primaryColor = Colors.blue,
  Color backgroundColor = Colors.black,
  Color textColor = Colors.white,
  bool showDebugInfo = false,
})
```

**Returns:** `Future<VerificationResult?>` - The verification result or null if cancelled

#### `showVerificationModal`

Shows face verification as a modal bottom sheet.

```dart
static Future<VerificationResult?> showVerificationModal(
  BuildContext context, {
  FaceVerificationConfig? config,
  int timeoutPerStep = 5,
  Function(String)? onError,
  Function(VerificationStep)? onStepChanged,
  Function(FaceData)? onFaceDetected,
  Widget Function(BuildContext context)? customOverlay,
  Widget Function(BuildContext context, String instruction)? customInstructions,
  Color primaryColor = Colors.blue,
  Color backgroundColor = Colors.black,
  Color textColor = Colors.white,
  bool showDebugInfo = false,
  double height = 0.9,
})
```

**Parameters:**
- `height`: Modal height as percentage of screen height (default: 0.9)

## FaceVerificationConfig

Configuration class for customizing the verification process.

```dart
class FaceVerificationConfig {
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
}
```

### Properties

- **`timeoutPerStep`** (`int`): Timeout for each verification step in seconds (default: 5)
- **`smileThreshold`** (`double`): Minimum confidence for smile detection (0.0-1.0, default: 0.7)
- **`eyeOpenThreshold`** (`double`): Minimum confidence for eye open detection (0.0-1.0, default: 0.5)
- **`eyeClosedThreshold`** (`double`): Maximum confidence for eye closed detection (0.0-1.0, default: 0.3)
- **`maxHeadRotation`** (`double`): Maximum allowed head rotation in degrees (default: 15.0)
- **`saveImages`** (`bool`): Whether to save face images automatically (default: true)
- **`saveDirectory`** (`String?`): Directory to save face images (null for default)
- **`imageQuality`** (`double`): Image quality (0.0-1.0, default: 0.9)
- **`numberOfImages`** (`int`): Number of face images to capture (default: 3)

### Methods

#### `copyWith`

Creates a copy of the configuration with modified parameters.

```dart
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
})
```

## VerificationResult

Contains the result of a face verification process.

```dart
class VerificationResult {
  const VerificationResult({
    required this.success,
    required this.faceImagePaths,
    required this.faceData,
    this.errorMessage,
    this.verificationDuration,
  });
}
```

### Properties

- **`success`** (`bool`): Whether the verification was successful
- **`faceImagePaths`** (`List<String>`): List of face image paths that were captured
- **`faceData`** (`List<FaceData>`): List of face data detected during verification
- **`errorMessage`** (`String?`): Error message if verification failed
- **`verificationDuration`** (`Duration?`): Total time taken for verification

### Factory Constructors

#### `VerificationResult.success`

Creates a successful verification result.

```dart
factory VerificationResult.success({
  required List<String> faceImagePaths,
  required List<FaceData> faceData,
  Duration? verificationDuration,
})
```

#### `VerificationResult.failure`

Creates a failed verification result.

```dart
factory VerificationResult.failure({
  required String errorMessage,
  Duration? verificationDuration,
})
```

## FaceData

Contains information about a detected face.

```dart
class FaceData {
  const FaceData({
    required this.boundingBox,
    required this.headEulerAngleY,
    required this.headEulerAngleZ,
    required this.leftEyeOpenProbability,
    required this.rightEyeOpenProbability,
    required this.smilingProbability,
    required this.trackingId,
  });
}
```

### Properties

- **`boundingBox`** (`Rect`): Bounding box of the detected face
- **`headEulerAngleY`** (`double?`): Head rotation around Y-axis (yaw)
- **`headEulerAngleZ`** (`double?`): Head rotation around Z-axis (roll)
- **`leftEyeOpenProbability`** (`double?`): Probability that left eye is open (0.0-1.0)
- **`rightEyeOpenProbability`** (`double?`): Probability that right eye is open (0.0-1.0)
- **`smilingProbability`** (`double?`): Probability that person is smiling (0.0-1.0)
- **`trackingId`** (`int?`): Unique tracking ID for the face

### Methods

#### `isSmiling`

Checks if the person is smiling based on threshold.

```dart
bool isSmiling({double threshold = 0.7})
```

#### `areEyesOpen`

Checks if both eyes are open based on threshold.

```dart
bool areEyesOpen({double threshold = 0.5})
```

#### `areEyesClosed`

Checks if both eyes are closed based on threshold.

```dart
bool areEyesClosed({double threshold = 0.3})
```

#### `hasGoodHeadPose`

Checks if head pose is within acceptable limits.

```dart
bool hasGoodHeadPose({
  double maxYaw = 15.0,
  double maxRoll = 15.0,
})
```

## VerificationStep

Enum representing the different verification steps.

```dart
enum VerificationStep {
  faceDetection,
  smileDetection,
  eyeCloseDetection,
  eyeOpenDetection,
  completed,
}
```

### Values

- **`faceDetection`**: Initial face detection step
- **`smileDetection`**: User must smile for the camera
- **`eyeCloseDetection`**: User must close their eyes
- **`eyeOpenDetection`**: User must open their eyes wide
- **`completed`**: Verification process completed

## Callbacks

### Verification Complete Callback

```dart
typedef VerificationCompleteCallback = void Function(VerificationResult result);
```

Called when the verification process completes (success or failure).

### Error Callback

```dart
typedef ErrorCallback = void Function(String error);
```

Called when an error occurs during verification.

### Step Changed Callback

```dart
typedef StepChangedCallback = void Function(VerificationStep step);
```

Called when the verification step changes.

### Face Detected Callback

```dart
typedef FaceDetectedCallback = void Function(FaceData faceData);
```

Called when a face is detected in the camera feed.

### Custom Overlay Builder

```dart
typedef CustomOverlayBuilder = Widget Function(BuildContext context);
```

Builder function for creating custom overlay widgets.

### Custom Instructions Builder

```dart
typedef CustomInstructionsBuilder = Widget Function(
  BuildContext context, 
  String instruction
);
```

Builder function for creating custom instruction widgets.

## Usage Examples

### Basic Usage

```dart
import 'package:face_detected/face_detected.dart';

// Simple widget integration
FaceVerification.createWidget(
  onVerificationComplete: (VerificationResult result) {
    if (result.success) {
      print('Verification successful!');
    } else {
      print('Verification failed: ${result.errorMessage}');
    }
  },
)
```

### Advanced Configuration

```dart
final config = FaceVerificationConfig(
  timeoutPerStep: 10,
  smileThreshold: 0.8,
  eyeOpenThreshold: 0.6,
  eyeClosedThreshold: 0.2,
  maxHeadRotation: 10.0,
  saveImages: true,
  imageQuality: 0.95,
);

FaceVerification.createWidget(
  config: config,
  primaryColor: Colors.green,
  backgroundColor: Colors.grey[900]!,
  textColor: Colors.white,
  showDebugInfo: true,
  onVerificationComplete: (result) {
    // Handle verification result
  },
  onStepChanged: (step) {
    print('Current step: ${step.toString()}');
  },
  onFaceDetected: (faceData) {
    print('Face detected with ${faceData.smilingProbability} smile probability');
  },
  onError: (error) {
    print('Error: $error');
  },
);
```

### Full Screen Verification

```dart
void startVerification() async {
  final result = await FaceVerification.showVerificationPage(
    context,
    config: FaceVerificationConfig(
      timeoutPerStep: 15,
      saveImages: true,
    ),
    primaryColor: Colors.blue,
  );
  
  if (result != null && result.success) {
    print('Verification completed in ${result.verificationDuration?.inSeconds}s');
    
    // Display captured images
    for (int i = 0; i < result.faceImagePaths.length; i++) {
      final imagePath = result.faceImagePaths[i];
      print('Image ${i + 1}: $imagePath');
    }
  }
}
```

## Error Handling

The package provides comprehensive error handling:

```dart
FaceVerification.createWidget(
  onVerificationComplete: (result) {
    if (!result.success) {
      switch (result.errorMessage) {
        case 'Camera permission denied':
          // Handle camera permission error
          break;
        case 'No cameras available':
          // Handle no camera error
          break;
        case 'Face detection timeout':
          // Handle timeout error
          break;
        default:
          // Handle other errors
          break;
      }
    }
  },
  onError: (error) {
    // Handle real-time errors
    print('Real-time error: $error');
  },
);
```

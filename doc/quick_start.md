# Quick Setup Guide

## 1. Installation

```yaml
dependencies:
  face_detected: ^0.0.1
```

```bash
flutter pub get
```

## 2. Permissions

### Android
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

### iOS
```xml
<!-- ios/Runner/Info.plist -->
<key>NSCameraUsageDescription</key>
<string>Camera access for face verification</string>
```

## 3. Basic Usage

```dart
import 'package:face_detected/face_detected.dart';

// Method 1: Full Screen
final result = await FaceVerification.showVerificationPage(context);

// Method 2: Widget
FaceVerification.createWidget(
  onVerificationComplete: (result) {
    if (result.success) {
      print('Success! ${result.faceImagePaths.length} images captured');
    }
  },
)

// Method 3: Modal
final result = await FaceVerification.showVerificationModal(context);
```

## 4. Configuration

```dart
final config = FaceVerificationConfig(
  timeoutPerStep: 10,        // seconds
  smileThreshold: 0.8,       // 0.0-1.0
  saveImages: true,
  imageQuality: 0.9,         // 0.0-1.0
);
```

## 5. Customization

```dart
FaceVerification.createWidget(
  config: config,
  primaryColor: Colors.blue,
  backgroundColor: Colors.black,
  textColor: Colors.white,
  onVerificationComplete: (result) {
    // Handle result
  },
);
```

## 6. Result Handling

```dart
void handleResult(VerificationResult result) {
  if (result.success) {
    print('✅ Success!');
    print('📸 Images: ${result.faceImagePaths}');
    print('⏱️ Duration: ${result.verificationDuration}');
  } else {
    print('❌ Failed: ${result.errorMessage}');
  }
}
```

## Verification Steps

1. **Face Detection** - Detect user's face
2. **Smile** - User must smile
3. **Eyes Closed** - User must close eyes
4. **Eyes Open** - User must open eyes wide

That's it! 🎉

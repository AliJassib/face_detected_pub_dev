# Face Detected

A comprehensive Flutter package for intelligent face verification with multi-step authentication using facial expressions and gestures.

## Features

✨ **Multi-Step Verification** - Face detection → Smile → Eyes closed → Eyes open  
📱 **Cross-Platform** - Android & iOS support  
🛡️ **Secure** - On-device ML Kit face detection  
🎨 **Customizable** - Full UI customization  
📸 **Auto Capture** - Automatic image capture  
⚡ **Real-time** - Fast face detection  

## Quick Start

```dart
import 'package:face_detected/face_detected.dart';

// Simple usage
final result = await FaceVerification.showVerificationPage(context);

if (result != null && result.success) {
  print('Verification successful!');
  print('Captured ${result.faceImagePaths.length} images');
}
```

## Configuration

```dart
final config = FaceVerificationConfig(
  timeoutPerStep: 10,
  smileThreshold: 0.8,
  saveImages: true,
  imageQuality: 0.9,
);

FaceVerification.createWidget(
  config: config,
  primaryColor: Colors.blue,
  onVerificationComplete: (result) {
    // Handle verification result
  },
);
```

## Permissions

### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

### iOS (`ios/Runner/Info.plist`)
```xml
<key>NSCameraUsageDescription</key>
<string>Camera access for face verification</string>
```

## Platform Support

- ✅ Android (API 21+)
- ✅ iOS (11.0+)
- ❌ Web (Camera limitations)
- ❌ Desktop (Camera limitations)

Perfect for secure authentication, identity verification, and biometric applications.

[Documentation](https://github.com/AliJassib/face_detected_pub_dev) | [Example](https://github.com/AliJassib/face_detected_pub_dev/tree/main/example) | [API Reference](https://pub.dev/documentation/face_detected/latest/)

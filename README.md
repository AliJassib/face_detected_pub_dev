# Face Detected - Flutter Face Verification Package

<div align="center">


**Face Verification** is a comprehensive Flutter package that provides intelligent face verification capabilities with multi-step authentication using facial expressions and gestures.

[![pub package](https://img.shields.io/pub/v/face_detected.svg)](https://pub.dev/packages/face_detected)



</div>

## ✨ Features

- 🎯 **Multi-Step Verification**: Smile detection, eye blink detection, and face pose validation
- 📱 **Cross-Platform**: Works on both Android and iOS
- 🛡️ **Secure**: Uses Google ML Kit for on-device face detection
- 🎨 **Customizable UI**: Fully customizable verification interface
- 📸 **Image Capture**: Automatically captures verification images
- ⚡ **Real-time Processing**: Fast and responsive face detection
- 🔧 **Easy Integration**: Simple API with minimal setup

## 📱 Verification Steps

1. **Face Detection** - Detects user's face in camera view
2. **Smile Verification** - User must smile for the camera
3. **Eyes Closed** - User must close their eyes
4. **Eyes Open** - User must open their eyes wide

## 🚀 Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  face_detected: ^0.0.2
```

Then run:

```bash
flutter pub get
```

## 🔧 Platform Setup

### Android Setup

#### 1. Add Permissions

Add the following permissions to your `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Camera permissions -->
    <uses-permission android:name="android.permission.CAMERA" />
    
    <!-- Storage permissions for saving images -->
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
    
    <!-- Audio permission (optional, for video recording) -->
    <uses-permission android:name="android.permission.RECORD_AUDIO" />
    
    <!-- Camera features -->
    <uses-feature
        android:name="android.hardware.camera"
        android:required="true" />
    <uses-feature
        android:name="android.hardware.camera.front"
        android:required="false" />
    <uses-feature
        android:name="android.hardware.camera.autofocus"
        android:required="false" />

    <application>
        <!-- Your app configuration -->
    </application>
</manifest>
```

#### 2. Minimum SDK Version

Ensure your `android/app/build.gradle` has minimum SDK version 21:

```gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        minSdkVersion 21  // Required for ML Kit
        targetSdkVersion 34
    }
}
```

### iOS Setup

#### 1. Add Permissions

Add the following to your `ios/Runner/Info.plist`:

```xml
<dict>
    <!-- Camera permission -->
    <key>NSCameraUsageDescription</key>
    <string>This app needs camera access to verify your face</string>
    
    <!-- Photo library permission -->
    <key>NSPhotoLibraryUsageDescription</key>
    <string>This app needs photo library access to save verification images</string>
    
    <!-- Microphone permission (optional) -->
    <key>NSMicrophoneUsageDescription</key>
    <string>This app needs microphone access for video recording</string>
</dict>
```

#### 2. Minimum iOS Version

Ensure your `ios/Podfile` has minimum iOS version 11.0:

```ruby
platform :ios, '11.0'
```

## 💡 Basic Usage

### Simple Implementation

```dart
import 'package:flutter/material.dart';
import 'package:face_detected/face_detected.dart';

class FaceVerificationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FaceVerification.createWidget(
        onVerificationComplete: (VerificationResult result) {
          if (result.success) {
            print('Verification successful!');
            print('Captured ${result.faceImagePaths.length} images');
            // Handle successful verification
          } else {
            print('Verification failed: ${result.errorMessage}');
            // Handle failed verification
          }
        },
        onError: (String error) {
          print('Error: $error');
        },
        onStepChanged: (VerificationStep step) {
          print('Current step: ${step.toString()}');
        },
      ),
    );
  }
}
```

### Full Screen Verification

```dart
void _startVerification() async {
  final result = await FaceVerification.showVerificationPage(
    context,
    timeoutPerStep: 10, // 10 seconds per step
    primaryColor: Colors.blue,
    backgroundColor: Colors.black,
    textColor: Colors.white,
  );
  
  if (result != null && result.success) {
    print('Verification completed successfully!');
    // Access captured images
    for (String imagePath in result.faceImagePaths) {
      print('Image saved at: $imagePath');
    }
  }
}
```

### Modal Bottom Sheet

```dart
void _showVerificationModal() async {
  final result = await FaceVerification.showVerificationModal(
    context,
    height: 0.8, // 80% of screen height
    config: FaceVerificationConfig(
      timeoutPerStep: 15,
      saveImages: true,
      imageQuality: 0.9,
    ),
  );
  
  // Handle result
}
```

## ⚙️ Configuration

### FaceVerificationConfig

Customize the verification process with `FaceVerificationConfig`:

```dart
final config = FaceVerificationConfig(
  timeoutPerStep: 10,          // Timeout for each step (seconds)
  smileThreshold: 0.7,         // Smile detection sensitivity (0.0-1.0)
  eyeOpenThreshold: 0.5,       // Eye open detection threshold
  eyeClosedThreshold: 0.3,     // Eye closed detection threshold
  maxHeadRotation: 15.0,       // Maximum head rotation (degrees)
  saveImages: true,            // Save captured images
  saveDirectory: null,         // Custom save directory (null for default)
  imageQuality: 0.9,          // Image quality (0.0-1.0)
  numberOfImages: 3,          // Number of images to capture
);

// Use the config
FaceVerification.createWidget(
  config: config,
  onVerificationComplete: (result) {
    // Handle result
  },
);
```

## 🎨 Customization

### Custom Colors and Theme

```dart
FaceVerification.createWidget(
  primaryColor: Colors.green,
  backgroundColor: Colors.grey[900]!,
  textColor: Colors.white,
  onVerificationComplete: (result) {
    // Handle result
  },
);
```

### Custom Instructions

```dart
FaceVerification.createWidget(
  customInstructions: (context, instruction) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        instruction,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
        textAlign: TextAlign.center,
      ),
    );
  },
  onVerificationComplete: (result) {
    // Handle result
  },
);
```

### Custom Overlay

```dart
FaceVerification.createWidget(
  customOverlay: (context) {
    return Positioned(
      top: 100,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.all(16),
        child: Text(
          'Custom Overlay Message',
          style: TextStyle(color: Colors.yellow, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ),
    );
  },
  onVerificationComplete: (result) {
    // Handle result
  },
);
```

## 📊 Verification Result

The `VerificationResult` object contains:

```dart
class VerificationResult {
  final bool success;                    // Whether verification succeeded
  final List<String> faceImagePaths;    // Paths to captured images
  final List<FaceData> faceData;        // Face detection data
  final String? errorMessage;           // Error message if failed
  final Duration? verificationDuration; // Time taken for verification
}
```

### Accessing Results

```dart
void handleVerificationResult(VerificationResult result) {
  if (result.success) {
    print('✅ Verification successful!');
    print('📸 Captured ${result.faceImagePaths.length} images');
    print('⏱️ Duration: ${result.verificationDuration?.inSeconds}s');
    
    // Display images
    for (int i = 0; i < result.faceImagePaths.length; i++) {
      final imagePath = result.faceImagePaths[i];
      final labels = ['Smile', 'Eyes Closed', 'Eyes Open'];
      print('${labels[i]}: $imagePath');
    }
    
    // Access face data
    for (FaceData face in result.faceData) {
      print('Face confidence: ${face.boundingBox}');
    }
  } else {
    print('❌ Verification failed: ${result.errorMessage}');
  }
}
```

## 📱 Example Implementation

Here's a complete example showing how to display captured images:

```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:face_detected/face_detected.dart';

class VerificationScreen extends StatefulWidget {
  @override
  _VerificationScreenState createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  VerificationResult? _result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Face Verification')),
      body: _result == null ? _buildVerificationView() : _buildResultView(),
    );
  }

  Widget _buildVerificationView() {
    return FaceVerification.createWidget(
      config: FaceVerificationConfig(
        timeoutPerStep: 10,
        saveImages: true,
        imageQuality: 0.9,
      ),
      onVerificationComplete: (result) {
        setState(() {
          _result = result;
        });
      },
      onError: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      },
    );
  }

  Widget _buildResultView() {
    final result = _result!;
    
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Status
          Row(
            children: [
              Icon(
                result.success ? Icons.check_circle : Icons.error,
                color: result.success ? Colors.green : Colors.red,
                size: 32,
              ),
              SizedBox(width: 12),
              Text(
                result.success ? 'Verification Successful' : 'Verification Failed',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 20),
          
          // Images
          if (result.success && result.faceImagePaths.isNotEmpty)
            Expanded(child: _buildImageGrid()),
          
          // Retry button
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _result = null;
              });
            },
            child: Text('Verify Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGrid() {
    final labels = ['Smile', 'Eyes Closed', 'Eyes Open'];
    
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        childAspectRatio: 1.2,
        mainAxisSpacing: 16,
      ),
      itemCount: _result!.faceImagePaths.length,
      itemBuilder: (context, index) {
        final imagePath = _result!.faceImagePaths[index];
        final label = index < labels.length ? labels[index] : 'Image ${index + 1}';
        
        return Card(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  label,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: Image.file(
                  File(imagePath),
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
```

## 🔧 Troubleshooting

### Common Issues

1. **Camera not working**
   - Ensure camera permissions are granted
   - Check device has a front-facing camera
   - Verify minimum SDK versions are met

2. **Face detection not working**
   - Ensure good lighting conditions
   - Face should be clearly visible
   - Adjust detection thresholds in config

3. **Images not saving**
   - Check storage permissions
   - Verify write access to storage
   - Ensure sufficient storage space

### Debug Mode

Enable debug information:

```dart
FaceVerification.createWidget(
  showDebugInfo: true,
  onVerificationComplete: (result) {
    // Handle result
  },
);
```

## 📋 Requirements

- **Flutter**: >=3.3.0
- **Dart**: >=3.9.2
- **Android**: API level 21+
- **iOS**: 11.0+

## 🤝 Contributing

Contributions are welcome! Please read our [Contributing Guide](CONTRIBUTING.md) for details.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

- 📧 Email: support@alijassib.com
- 🐛 Issues: [GitHub Issues](https://github.com/AliJassib/face_detected_pub_dev/issues)
- 📖 Documentation: [API Documentation](https://pub.dev/documentation/face_detected/latest/)

## 🏷️ Tags

`face-detection` `face-verification` `biometric` `authentication` `flutter` `dart` `ml-kit` `camera` `security`

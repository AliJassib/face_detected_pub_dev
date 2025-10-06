# Face Detected Example

This example demonstrates how to use the **face_detected** package for face verification in Flutter applications.

## 🚀 Getting Started

### Prerequisites

Before running this example, ensure you have:

- Flutter SDK (>=3.3.0) installed
- Physical device or emulator with camera
- Proper permissions configured

### Setup Instructions

1. **Clone the repository**
   ```bash
   git clone https://github.com/AliJassib/face_detected_pub_dev.git
   cd face_detected_pub_dev/example
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure permissions** (see below)

4. **Run the example**
   ```bash
   flutter run
   ```

## 📱 Platform Configuration

### Android

Add these permissions to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />

<uses-feature android:name="android.hardware.camera" android:required="true" />
<uses-feature android:name="android.hardware.camera.front" android:required="false" />
```

### iOS

Add these to `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to verify your face</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs photo library access to save verification images</string>
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access for video recording</string>
```

## 🎯 Features Demonstrated

### 1. Basic Face Verification
- Simple integration with default settings
- Automatic image capture
- Result display with captured images

### 2. Custom Configuration
- Adjustable timeouts
- Custom detection thresholds
- Image quality settings

### 3. UI Customization
- Custom colors and themes
- Custom instruction messages
- Responsive design

### 4. Error Handling
- Permission handling
- Camera initialization errors
- Verification timeout handling

## 📖 Code Examples

### Simple Usage

```dart
import 'package:face_detected/face_detected.dart';

void _startVerification() async {
  final result = await FaceVerification.showVerificationPage(
    context,
    timeoutPerStep: 10,
    onStepChanged: (step) {
      print('Step changed: ${step.name}');
    },
    onFaceDetected: (faceData) {
      print('Face detected: ${faceData.smilingProbability}');
    },
  );
  
  if (result != null && result.success) {
    print('Verification successful!');
    // Handle success
  }
}
```

### Custom Configuration

```dart
final config = FaceVerificationConfig(
  timeoutPerStep: 15,
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
  backgroundColor: Colors.black,
  textColor: Colors.white,
  onVerificationComplete: (result) {
    // Handle result
  },
);
```

### Displaying Results

```dart
Widget _buildResultCard() {
  return Card(
    child: Column(
      children: [
        // Status indicator
        Row(
          children: [
            Icon(
              _result.success ? Icons.check_circle : Icons.error,
              color: _result.success ? Colors.green : Colors.red,
            ),
            Text(_result.success ? 'Success' : 'Failed'),
          ],
        ),
        
        // Captured images
        if (_result.faceImagePaths.isNotEmpty)
          _buildImageGrid(_result.faceImagePaths),
      ],
    ),
  );
}

Widget _buildImageGrid(List<String> imagePaths) {
  final labels = ['Smile', 'Eyes Closed', 'Eyes Open'];
  
  return Container(
    height: 200,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: imagePaths.length,
      itemBuilder: (context, index) {
        return Container(
          width: 150,
          margin: EdgeInsets.only(right: 12),
          child: Column(
            children: [
              Text(labels[index]),
              Expanded(
                child: Image.file(
                  File(imagePaths[index]),
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}
```

## 🎨 Customization Examples

### Custom Theme

```dart
FaceVerification.createWidget(
  primaryColor: Colors.purple,
  backgroundColor: Colors.grey[900]!,
  textColor: Colors.white,
  customInstructions: (context, instruction) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        instruction,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.purple,
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
        child: Card(
          color: Colors.black54,
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              'Please follow the instructions carefully',
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  },
  onVerificationComplete: (result) {
    // Handle result
  },
);
```

## 🔧 Troubleshooting

### Common Issues

1. **Camera not working**
   ```
   Solution: Check camera permissions in device settings
   ```

2. **Face detection not working**
   ```
   Solution: Ensure good lighting and face is clearly visible
   ```

3. **App crashes on startup**
   ```
   Solution: Check minimum SDK versions and dependencies
   ```

4. **Images not saving**
   ```
   Solution: Check storage permissions and available space
   ```

### Debug Mode

Enable debug information to troubleshoot issues:

```dart
FaceVerification.createWidget(
  showDebugInfo: true,
  onVerificationComplete: (result) {
    print('Debug: $result');
  },
  onError: (error) {
    print('Debug Error: $error');
  },
);
```

## 📊 Performance Tips

1. **Optimize detection thresholds** based on your use case
2. **Adjust image quality** to balance file size and quality
3. **Set appropriate timeouts** for better user experience
4. **Test on various devices** to ensure compatibility

## 🧪 Testing

Run the example tests:

```bash
flutter test
```

Test on different devices:

```bash
# iOS Simulator
flutter run -d ios

# Android Emulator
flutter run -d android

# Physical device
flutter devices
flutter run -d [device-id]
```

## 📱 Supported Platforms

- ✅ **Android** (API 21+)
- ✅ **iOS** (11.0+)
- ❌ **Web** (Camera access limitations)
- ❌ **Desktop** (Camera access limitations)

## 📞 Support

If you encounter any issues with the example:

1. Check the [troubleshooting guide](../doc/troubleshooting.md)
2. Review the [API documentation](../doc/api.md)
3. Open an issue on [GitHub](https://github.com/AliJassib/face_detected_pub_dev/issues)
4. Contact support: support@alijassib.com

## 🤝 Contributing

Want to improve the example? See our [contributing guide](../CONTRIBUTING.md).

## 📄 License

This example is part of the face_detected package and is licensed under the MIT License.

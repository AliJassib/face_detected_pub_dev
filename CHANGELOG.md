# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.1] - 2024-10-06

### Added
- 🎯 Multi-step face verification (Face Detection → Smile → Eyes Closed → Eyes Open)
- 📱 Cross-platform support for Android and iOS
- 🛡️ Google ML Kit integration for secure on-device face detection
- 📸 Automatic image capture for each verification step
- 🎨 Fully customizable UI with themes and colors
- ⚙️ Comprehensive configuration options
- 🔧 Three integration methods: Widget, Full Screen, Modal
- 📊 Detailed verification results with captured images
- 🚀 Real-time face detection and processing
- 🎭 Custom overlays and instruction widgets
- 📱 Responsive design for all screen sizes
- 🔒 Secure local image storage
- 📋 Comprehensive permission handling
- 🐛 Debug mode for troubleshooting
- 📖 Extensive documentation and examples

### Features
- **Face Detection**: Real-time face detection with pose validation
- **Smile Verification**: Detects genuine smiles with configurable threshold
- **Eye Blink Detection**: Validates eye closure and opening
- **Image Quality Control**: Configurable image quality and compression
- **Custom Theming**: Full UI customization support
- **Error Handling**: Comprehensive error handling and reporting
- **Timeout Management**: Configurable timeouts for each verification step
- **Platform Optimization**: Optimized for both Android (YUV420) and iOS (BGRA8888)

### Technical Details
- Minimum Flutter version: 3.3.0
- Minimum Dart SDK: 3.9.2
- Android minimum SDK: 21
- iOS minimum version: 11.0
- Google ML Kit Face Detection
- Camera plugin integration
- GetX state management
- Image processing utilities

### Platform Support
- ✅ Android (API 21+)
- ✅ iOS (11.0+)
- 🚫 Web (Not supported - requires camera access)
- 🚫 Desktop (Not supported - requires camera access)

### Dependencies
- flutter: SDK
- plugin_platform_interface: ^2.1.7
- cupertino_icons: ^1.0.8
- get: ^4.7.2
- google_ml_kit: ^0.20.0
- camera: ^0.11.1
- path_provider: ^2.1.5
- image_gallery_saver_plus: ^4.0.1
- image: ^4.2.0

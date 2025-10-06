import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'face_detected_platform_interface.dart';

/// An implementation of [FaceDetectedPlatform] that uses method channels.
class MethodChannelFaceDetected extends FaceDetectedPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('face_detected');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }
}

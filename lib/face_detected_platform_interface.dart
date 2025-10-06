import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'face_detected_method_channel.dart';

abstract class FaceDetectedPlatform extends PlatformInterface {
  /// Constructs a FaceDetectedPlatform.
  FaceDetectedPlatform() : super(token: _token);

  static final Object _token = Object();

  static FaceDetectedPlatform _instance = MethodChannelFaceDetected();

  /// The default instance of [FaceDetectedPlatform] to use.
  ///
  /// Defaults to [MethodChannelFaceDetected].
  static FaceDetectedPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FaceDetectedPlatform] when
  /// they register themselves.
  static set instance(FaceDetectedPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}

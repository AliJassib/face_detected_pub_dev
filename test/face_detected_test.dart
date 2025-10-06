import 'package:face_detected/face_detected.dart';
import 'package:face_detected/face_detected_method_channel.dart';
import 'package:face_detected/face_detected_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFaceDetectedPlatform
    with MockPlatformInterfaceMixin
    implements FaceDetectedPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FaceDetectedPlatform initialPlatform = FaceDetectedPlatform.instance;

  test('$MethodChannelFaceDetected is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFaceDetected>());
  });

  test('getPlatformVersion', () async {
    FaceDetected faceDetectedPlugin = FaceDetected();
    MockFaceDetectedPlatform fakePlatform = MockFaceDetectedPlatform();
    FaceDetectedPlatform.instance = fakePlatform;

    expect(await faceDetectedPlugin.getPlatformVersion(), '42');
  });
}

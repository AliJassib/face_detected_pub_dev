import 'dart:io';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

import '../models/face_data.dart';

/// Service for handling face detection using Google ML Kit
class FaceDetectionService {
  late FaceDetector _faceDetector;
  bool _isInitialized = false;

  /// Initialize the face detection service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _faceDetector = FaceDetector(
        options: FaceDetectorOptions(
          enableClassification: true,
          enableLandmarks: true,
          enableContours: true,
          enableTracking: true,
          minFaceSize: 0.1, // Reduced from 0.1 to detect smaller faces
          performanceMode: FaceDetectorMode
              .accurate, // Use accurate mode for better detection
        ),
      );
      _isInitialized = true;
      debugPrint('Face detector initialized successfully');
    } catch (e) {
      debugPrint('Error initializing face detector: $e');
      rethrow;
    }
  }

  /// Dispose the face detection service
  Future<void> dispose() async {
    if (_isInitialized) {
      try {
        await _faceDetector.close();
        _isInitialized = false;
      } catch (e) {
        debugPrint('Error disposing face detector: $e');
      }
    }
  }

  /// Detect faces in a camera image
  Future<List<FaceData>> detectFacesFromCameraImage(CameraImage image) async {
    if (!_isInitialized) {
      throw StateError(
        'FaceDetectionService not initialized. Call initialize() first.',
      );
    }

    // Validate image
    if (image.planes.isEmpty) {
      debugPrint('Camera image has no planes');
      return [];
    }

    final inputImage = _convertCameraImageToInputImage(image);
    if (inputImage == null) {
      debugPrint('Failed to convert camera image to input image');
      return [];
    }

    try {
      final faces = await _faceDetector.processImage(inputImage);
      return faces.map((face) => FaceData.fromFace(face)).toList();
    } catch (e) {
      debugPrint('Error detecting faces: $e');
      return [];
    }
  }

  /// Detect faces in an image file
  Future<List<FaceData>> detectFacesFromFile(File imageFile) async {
    if (!_isInitialized) {
      throw StateError(
        'FaceDetectionService not initialized. Call initialize() first.',
      );
    }

    if (!await imageFile.exists()) {
      debugPrint('Image file does not exist: ${imageFile.path}');
      return [];
    }

    final inputImage = InputImage.fromFile(imageFile);
    try {
      final faces = await _faceDetector.processImage(inputImage);
      return faces.map((face) => FaceData.fromFace(face)).toList();
    } catch (e) {
      debugPrint('Error detecting faces from file: $e');
      return [];
    }
  }

  /// Detect faces from image bytes
  Future<List<FaceData>> detectFacesFromBytes(
    Uint8List bytes, {
    required int width,
    required int height,
    required InputImageFormat format,
  }) async {
    if (!_isInitialized) {
      throw StateError(
        'FaceDetectionService not initialized. Call initialize() first.',
      );
    }

    if (bytes.isEmpty || width <= 0 || height <= 0) {
      debugPrint('Invalid image parameters');
      return [];
    }

    final inputImage = InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(width.toDouble(), height.toDouble()),
        rotation: InputImageRotation.rotation0deg,
        format: format,
        bytesPerRow: width * 4, // Assuming RGBA format
      ),
    );

    try {
      final faces = await _faceDetector.processImage(inputImage);
      return faces.map((face) => FaceData.fromFace(face)).toList();
    } catch (e) {
      debugPrint('Error detecting faces from bytes: $e');
      return [];
    }
  }

  /// Convert CameraImage to InputImage with proper error handling
  InputImage? _convertCameraImageToInputImage(CameraImage image) {
    try {
      // Validate image format
      if (image.planes.isEmpty) {
        debugPrint('Image has no planes');
        return null;
      }

      final firstPlane = image.planes.first;
      final bytes = firstPlane.bytes;

      if (bytes.isEmpty) {
        debugPrint('Image bytes are empty');
        return null;
      }

      debugPrint(
        'Converting image: ${image.width}x${image.height}, format: ${image.format.group}',
      );

      // Get image rotation and format based on platform and image format
      InputImageRotation rotation = InputImageRotation.rotation0deg;
      InputImageFormat format;

      if (Platform.isIOS) {
        // For iOS front camera, rotate 270 degrees and use BGRA format
        rotation = InputImageRotation.rotation270deg;
        format = InputImageFormat.bgra8888;
      } else {
        // For Android, use YUV420 format and no rotation for front camera
        rotation = InputImageRotation.rotation0deg;
        format = InputImageFormat.nv21;

        // Check if this is YUV format and convert accordingly
        if (image.format.group == ImageFormatGroup.yuv420) {
          format = InputImageFormat.yuv420;
        }
      }

      // Create input image metadata with proper bytes per row
      final inputImageMetadata = InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: Platform.isIOS ? firstPlane.bytesPerRow : image.width,
      );

      // For multi-plane images (like YUV), concatenate all planes
      Uint8List allBytes;
      if (image.planes.length > 1) {
        // Concatenate all planes for YUV format
        List<int> combined = [];
        for (final plane in image.planes) {
          combined.addAll(plane.bytes);
        }
        allBytes = Uint8List.fromList(combined);
      } else {
        allBytes = bytes;
      }

      debugPrint(
        'Created InputImage with ${allBytes.length} bytes, rotation: $rotation, format: $format',
      );

      return InputImage.fromBytes(
        bytes: allBytes,
        metadata: inputImageMetadata,
      );
    } catch (e) {
      debugPrint('Error converting camera image: $e');
      return null;
    }
  }

  /// Check if service is initialized
  bool get isInitialized => _isInitialized;
}

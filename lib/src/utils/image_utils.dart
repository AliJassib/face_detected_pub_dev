import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import '../models/face_data.dart';

/// Utility class for image processing and manipulation
class ImageUtils {
  /// Convert CameraImage to Image format
  static img.Image? convertCameraImageToImage(CameraImage cameraImage) {
    try {
      if (cameraImage.format.group == ImageFormatGroup.yuv420) {
        return _convertYUV420ToImage(cameraImage);
      } else if (cameraImage.format.group == ImageFormatGroup.bgra8888) {
        return _convertBGRA8888ToImage(cameraImage);
      } else {
        print('Unsupported image format: ${cameraImage.format.group}');
        return null;
      }
    } catch (e) {
      print('Error converting camera image: $e');
      return null;
    }
  }

  /// Convert YUV420 format to Image
  static img.Image _convertYUV420ToImage(CameraImage cameraImage) {
    final width = cameraImage.width;
    final height = cameraImage.height;

    final yPlane = cameraImage.planes[0];
    final uPlane = cameraImage.planes[1];
    final vPlane = cameraImage.planes[2];

    final image = img.Image(width: width, height: height);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final yIndex = y * yPlane.bytesPerRow + x;
        final uvPixelStride = uPlane.bytesPerPixel ?? 1;
        final uvRowStride = uPlane.bytesPerRow;
        final uvIndex = (y ~/ 2) * uvRowStride + (x ~/ 2) * uvPixelStride;

        if (yIndex < yPlane.bytes.length &&
            uvIndex < uPlane.bytes.length &&
            uvIndex < vPlane.bytes.length) {
          final yValue = yPlane.bytes[yIndex];
          final uValue = uPlane.bytes[uvIndex];
          final vValue = vPlane.bytes[uvIndex];

          // Standard YUV to RGB conversion
          final c = yValue - 16;
          final d = uValue - 128;
          final e = vValue - 128;

          final r = ((298 * c + 409 * e + 128) >> 8).clamp(0, 255);
          final g = ((298 * c - 100 * d - 208 * e + 128) >> 8).clamp(0, 255);
          final b = ((298 * c + 516 * d + 128) >> 8).clamp(0, 255);

          image.setPixelRgb(x, y, r, g, b);
        }
      }
    }

    return image;
  }

  /// Convert BGRA8888 format to Image
  static img.Image _convertBGRA8888ToImage(CameraImage cameraImage) {
    final bytes = cameraImage.planes[0].bytes;
    final width = cameraImage.width;
    final height = cameraImage.height;

    final image = img.Image(width: width, height: height);

    // Convert BGRA to RGB manually for better color accuracy
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final index = (y * width + x) * 4;
        if (index + 3 < bytes.length) {
          final b = bytes[index];
          final g = bytes[index + 1];
          final r = bytes[index + 2];
          final a = bytes[index + 3];

          image.setPixelRgba(x, y, r, g, b, a);
        }
      }
    }

    return image;
  }

  /// Crop face from image using face data
  static img.Image? cropFace(
    img.Image originalImage,
    FaceData faceData, {
    double padding = 0.2,
  }) {
    try {
      final boundingBox = faceData.boundingBox;
      final paddingX = boundingBox.width * padding;
      final paddingY = boundingBox.height * padding;

      final x = (boundingBox.left - paddingX)
          .clamp(0, originalImage.width.toDouble())
          .toInt();
      final y = (boundingBox.top - paddingY)
          .clamp(0, originalImage.height.toDouble())
          .toInt();
      final width = (boundingBox.width + 2 * paddingX)
          .clamp(0, originalImage.width - x.toDouble())
          .toInt();
      final height = (boundingBox.height + 2 * paddingY)
          .clamp(0, originalImage.height - y.toDouble())
          .toInt();

      return img.copyCrop(
        originalImage,
        x: x,
        y: y,
        width: width,
        height: height,
      );
    } catch (e) {
      print('Error cropping face: $e');
      return null;
    }
  }

  /// Save image to file
  static Future<String?> saveImageToFile(
    img.Image image, {
    String? directory,
    String? filename,
    int quality = 90,
  }) async {
    try {
      final dir = directory != null
          ? Directory(directory)
          : await getApplicationDocumentsDirectory();

      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      final fileName =
          filename ?? 'face_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final file = File('${dir.path}/$fileName');

      final bytes = img.encodeJpg(image, quality: quality);
      await file.writeAsBytes(bytes);

      return file.path;
    } catch (e) {
      print('Error saving image: $e');
      return null;
    }
  }

  /// Save image to gallery
  static Future<bool> saveImageToGallery(
    img.Image image, {
    String? name,
    int quality = 90,
  }) async {
    try {
      final bytes = img.encodeJpg(image, quality: quality);
      final fileName =
          name ?? 'face_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final result = await ImageGallerySaverPlus.saveImage(
        Uint8List.fromList(bytes),
        name: fileName,
        quality: quality,
      );

      return result['isSuccess'] == true;
    } catch (e) {
      print('Error saving image to gallery: $e');
      return false;
    }
  }

  /// Resize image maintaining aspect ratio
  static img.Image resizeImage(
    img.Image image, {
    int? width,
    int? height,
    int maxSize = 1024,
  }) {
    if (width == null && height == null) {
      // Resize based on maxSize
      if (image.width > maxSize || image.height > maxSize) {
        if (image.width > image.height) {
          height = (maxSize * image.height / image.width).round();
          width = maxSize;
        } else {
          width = (maxSize * image.width / image.height).round();
          height = maxSize;
        }
      } else {
        return image;
      }
    }

    return img.copyResize(
      image,
      width: width,
      height: height,
      interpolation: img.Interpolation.cubic,
    );
  }

  /// Convert Image to Uint8List
  static Uint8List imageToBytes(img.Image image, {int quality = 90}) {
    return Uint8List.fromList(img.encodeJpg(image, quality: quality));
  }

  /// Get image dimensions from file
  static Future<Size?> getImageDimensions(String imagePath) async {
    try {
      final file = File(imagePath);
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image != null) {
        return Size(image.width.toDouble(), image.height.toDouble());
      }
      return null;
    } catch (e) {
      print('Error getting image dimensions: $e');
      return null;
    }
  }
}

/// Size class for image dimensions
class Size {
  final double width;
  final double height;

  const Size(this.width, this.height);

  @override
  String toString() => 'Size($width, $height)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Size && other.width == width && other.height == height;
  }

  @override
  int get hashCode => width.hashCode ^ height.hashCode;
}

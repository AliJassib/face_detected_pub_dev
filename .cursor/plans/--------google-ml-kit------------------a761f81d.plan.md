<!-- a761f81d-e426-4e21-99ee-8850d995a9f3 1ca4edc2-71f4-40b4-9091-efba0d44ead6 -->
# إصلاح تطابق رسم نقاط الوجه

## المشكلة

النقاط والخطوط مرسومة في مكان خاطئ (على اليسار) بدلاً من فوق الوجه مباشرة.

## السبب

الكاميرا معروضة باستخدام `BoxFit.cover` مما يسبب:

- تغيير في scale والأبعاد
- offset في الموضع
- دالة `_scalePoint()` لا تأخذ هذا التأثير بالحسبان

## الحل

### تعديل face_landmarks_painter.dart

سنعيد كتابة دالة `_scalePoint()` لتأخذ بعين الاعتبار:

1. Camera preview aspect ratio
2. Screen aspect ratio
3. BoxFit.cover effect (scaling + offset)
4. Platform differences (iOS vs Android)
5. Mirror effect للكاميرا الأمامية

الخطوات:

1. حساب scale factor الصحيح مع BoxFit.cover
2. حساب الـ offset الناتج من cover mode
3. تطبيق التحويلات الصحيحة للإحداثيات
4. معالجة الاختلافات بين iOS و Android

## الكود المطلوب

```dart
Offset _scalePoint(Offset point, Size size) {
  // Calculate BoxFit.cover scale and offset
  final double previewAspectRatio = cameraPreviewSize.width / cameraPreviewSize.height;
  final double screenAspectRatio = size.width / size.height;
  
  double scale;
  double offsetX = 0;
  double offsetY = 0;
  
  if (previewAspectRatio > screenAspectRatio) {
    // Preview is wider - fit height, crop width
    scale = size.height / cameraPreviewSize.height;
    offsetX = (cameraPreviewSize.width * scale - size.width) / 2;
  } else {
    // Preview is taller - fit width, crop height  
    scale = size.width / cameraPreviewSize.width;
    offsetY = (cameraPreviewSize.height * scale - size.height) / 2;
  }
  
  // Apply transformation
  if (Platform.isIOS) {
    // iOS front camera: rotated 270° 
    return Offset(
      size.width - (point.dy * scale - offsetX),
      point.dx * scale - offsetY,
    );
  } else {
    // Android front camera: mirrored
    return Offset(
      size.width - (point.dx * scale - offsetX),
      point.dy * scale - offsetY,
    );
  }
}
```

### To-dos

- [ ] تعديل دالة _scalePoint في face_landmarks_painter.dart لحساب BoxFit.cover بشكل صحيح
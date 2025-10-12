<!-- a761f81d-e426-4e21-99ee-8850d995a9f3 107345f2-ec5f-4c4d-8917-2c7416f86971 -->
# استبدال google_ml_kit بالمكتبة الجديدة

## الملفات المتأثرة

سيتم تعديل 3 ملفات فقط:

### 1. تحديث pubspec.yaml

**المسار:** `/Users/alijassib/Documents/ahmad jassim/face_detected/pubspec.yaml`

استبدال السطر 26:

```yaml
# من:
google_ml_kit: ^0.20.0

# إلى:
google_mlkit_face_detection: ^0.13.1
```

**السبب:** المكتبة الجديدة معيارية وأصغر حجماً وموصى بها من Google

---

### 2. تحديث face_detection_service.dart

**المسار:** `/Users/alijassib/Documents/ahmad jassim/face_detected/lib/src/services/face_detection_service.dart`

استبدال السطر 6:

```dart
// من:
import 'package:google_ml_kit/google_ml_kit.dart';

// إلى:
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
```

**ملاحظة:** باقي الكود يبقى كما هو بدون أي تغيير لأن API متطابقة

---

### 3. تحديث face_data.dart

**المسار:** `/Users/alijassib/Documents/ahmad jassim/face_detected/lib/src/models/face_data.dart`

استبدال السطر 2:

```dart
// من:
import 'package:google_ml_kit/google_ml_kit.dart';

// إلى:
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
```

---

## خطوات التنفيذ بعد التعديلات

### 4. تحديث الاعتماديات (Dependencies)

```bash
cd /Users/alijassib/Documents/ahmad\ jassim/face_detected
flutter pub get
```

### 5. تحديث iOS Pods

```bash
cd example/ios
pod install --repo-update
cd ../..
```

### 6. تنظيف المشروع

```bash
flutter clean
cd example
flutter clean
cd ..
```

### 7. إعادة البناء

```bash
cd example
flutter pub get
flutter run
```

---

## ملاحظات مهمة

1. **لا تغيير في الكود المنطقي:** جميع Classes والMethods تبقى كما هي:

   - `FaceDetector`
   - `FaceDetectorOptions`
   - `Face`
   - `FaceLandmark`, `FaceLandmarkType`
   - `FaceContour`, `FaceContourType`
   - كل الخصائص (smilingProbability, leftEyeOpenProbability, إلخ)

2. **الدقة متطابقة 100%:** لأن كلا المكتبتين تستخدم نفس Native APIs من Google

3. **المتطلبات متوافقة:**

   - iOS: deployment target 15.5 ✓ (موجود فعلاً)
   - Android: minSdk 24 ✓ (المطلوب 21 فقط)

4. **حجم التطبيق:** سينخفض لأن المكتبة الجديدة تحتوي فقط على Face Detection

5. **example/pubspec.yaml:** لا يحتاج تعديل لأنه يعتمد على المكتبة المحلية عبر `path: ../`

### To-dos

- [ ] تحديث pubspec.yaml الرئيسي باستبدال google_ml_kit بـ google_mlkit_face_detection
- [ ] تحديث import في face_detection_service.dart
- [ ] تحديث import في face_data.dart
- [ ] تشغيل flutter pub get في المشروع الرئيسي
- [ ] تشغيل pod install في example/ios
- [ ] تنظيف وإعادة بناء المشروع
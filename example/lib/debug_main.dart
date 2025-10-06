// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';


// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await initCameras();
//   runApp(const DebugFaceDetectionApp());
// }

// Future<void> initCameras() async {
//   try {
//     final cameras = await availableCameras();
//     print('Available cameras: ${cameras.length}');
//     for (var camera in cameras) {
//       print('Camera: ${camera.name}, Direction: ${camera.lensDirection}');
//     }
//   } catch (e) {
//     print('Error getting cameras: $e');
//   }
// }

// class DebugFaceDetectionApp extends StatelessWidget {
//   const DebugFaceDetectionApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       title: 'Debug Face Detection',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: const DebugFaceDetectionScreen(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }

// class DebugFaceDetectionScreen extends StatefulWidget {
//   const DebugFaceDetectionScreen({Key? key}) : super(key: key);

//   @override
//   State<DebugFaceDetectionScreen> createState() => _DebugFaceDetectionScreenState();
// }

// class _DebugFaceDetectionScreenState extends State<DebugFaceDetectionScreen> {
//   final FaceVerificationController controller = Get.put(FaceVerificationController());
//   String debugInfo = 'Initializing...';
//   List<String> logs = [];

//   @override
//   void initState() {
//     super.initState();
//     _initializeController();
//   }

//   void _initializeController() async {
//     try {
//       await controller.initialize(
//         verificationConfig: const FaceVerificationConfig(
//           timeoutPerStep: 30, // Longer timeout for testing
//           maxHeadRotation: 30.0, // More lenient head rotation
//           smileThreshold: 0.3, // Lower threshold
//           eyeOpenThreshold: 0.3, // Lower threshold
//           eyeClosedThreshold: 0.5, // Higher threshold for closed eyes
//           saveImages: false,
//         ),
//         onFaceDetection: (face) {
//           setState(() {
//             debugInfo = 'Face detected: ${face.toString()}';
//             logs.add('[${DateTime.now().toString().substring(11, 19)}] Face: ${face.toString()}');
//             if (logs.length > 10) logs.removeAt(0);
//           });
//         },
//         onErrorCallback: (error) {
//           setState(() {
//             debugInfo = 'Error: $error';
//             logs.add('[${DateTime.now().toString().substring(11, 19)}] Error: $error');
//             if (logs.length > 10) logs.removeAt(0);
//           });
//         },
//       );
//     } catch (e) {
//       setState(() {
//         debugInfo = 'Initialization failed: $e';
//         logs.add('[${DateTime.now().toString().substring(11, 19)}] Init Error: $e');
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Debug Face Detection'),
//         backgroundColor: Colors.blue,
//       ),
//       body: Column(
//         children: [
//           // Camera Preview
//           Expanded(
//             flex: 3,
//             child: Obx(() {
//               if (!controller.isCameraInitialized.value) {
//                 return const Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       CircularProgressIndicator(),
//                       SizedBox(height: 16),
//                       Text('Initializing Camera...'),
//                     ],
//                   ),
//                 );
//               }

//               return Stack(
//                 children: [
//                   // Camera Preview
//                   SizedBox(
//                     width: double.infinity,
//                     height: double.infinity,
//                     child: FittedBox(
//                       fit: BoxFit.cover,
//                       child: SizedBox(
//                         width: controller._cameraController!.value.previewSize!.height,
//                         height: controller._cameraController!.value.previewSize!.width,
//                         child: CameraPreview(controller._cameraController!),
//                       ),
//                     ),
//                   ),
                  
//                   // Face Detection Overlay
//                   Obx(() {
//                     final faces = controller.detectedFaces;
//                     if (faces.isEmpty) return const SizedBox();
                    
//                     return CustomPaint(
//                       painter: FaceOverlayPainter(faces),
//                       child: Container(),
//                     );
//                   }),
                  
//                   // Status Overlay
//                   Positioned(
//                     top: 16,
//                     left: 16,
//                     right: 16,
//                     child: Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: Colors.black54,
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Obx(() => Text(
//                         controller.statusMessage.value,
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                         textAlign: TextAlign.center,
//                       )),
//                     ),
//                   ),
//                 ],
//               );
//             }),
//           ),
          
//           // Debug Info
//           Container(
//             height: 200,
//             padding: const EdgeInsets.all(16),
//             color: Colors.grey[100],
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Debug Info:',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.grey[800],
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   debugInfo,
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.grey[700],
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   'Recent Logs:',
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.grey[800],
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Expanded(
//                   child: SingleChildScrollView(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: logs.map((log) => Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 1),
//                         child: Text(
//                           log,
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: Colors.grey[600],
//                           ),
//                         ),
//                       )).toList(),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     controller.dispose();
//     super.dispose();
//   }
// }

// class FaceOverlayPainter extends CustomPainter {
//   final List<FaceData> faces;

//   FaceOverlayPainter(this.faces);

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.green
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 2.0;

//     for (final face in faces) {
//       // Draw bounding box
//       canvas.drawRect(face.boundingBox, paint);
      
//       // Draw face info
//       final textPainter = TextPainter(
//         text: TextSpan(
//           text: 'Face ID: ${face.trackingId ?? 'N/A'}\n'
//                 'Smile: ${face.smilingProbability?.toStringAsFixed(2) ?? 'N/A'}\n'
//                 'Eyes: L${face.leftEyeOpenProbability?.toStringAsFixed(2) ?? 'N/A'} '
//                 'R${face.rightEyeOpenProbability?.toStringAsFixed(2) ?? 'N/A'}',
//           style: const TextStyle(
//             color: Colors.white,
//             fontSize: 12,
//             backgroundColor: Colors.black54,
//           ),
//         ),
//         textDirection: TextDirection.ltr,
//       );
      
//       textPainter.layout();
//       textPainter.paint(
//         canvas,
//         Offset(
//           face.boundingBox.left,
//           face.boundingBox.top - textPainter.height - 4,
//         ),
//       );
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }

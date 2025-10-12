import 'dart:io';

import 'package:face_detected/face_detected.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Face Detected Demo',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  VerificationResult? _lastResult;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Face Verification Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.face, size: 100, color: Colors.blue),
              const SizedBox(height: 24),
              const Text(
                'Face Verification Package Demo',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'This demo showcases face verification with smile detection, eye movement detection, and automatic face cropping.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _startFaceVerification,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Start Face Verification'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _startFaceVerificationModal,
                icon: const Icon(Icons.fullscreen),
                label: const Text('Open as Modal'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _startCustomVerification,
                icon: const Icon(Icons.settings),
                label: const Text('Custom Configuration'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 24),
              if (_lastResult != null) _buildResultCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    final result = _lastResult!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Row(
              children: [
                Icon(
                  result.success ? Icons.check_circle : Icons.error,
                  color: result.success ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  result.success
                      ? 'Verification Successful'
                      : 'Verification Failed',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (result.success) ...[
              Text('Captured Images: ${result.faceImagePaths.length}'),
              Text('Face Data: ${result.faceData.length}'),
              if (result.verificationDuration != null)
                Text('Duration: ${result.verificationDuration!.inSeconds}s'),
            ] else ...[
              Text('Error: ${result.errorMessage ?? 'Unknown error'}'),
            ],
            const SizedBox(height: 16),
            if (result.faceImagePaths.isNotEmpty) ...[
              const Text(
                'Captured Images:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildImageGrid(result.faceImagePaths),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildImageGrid(List<String> imagePaths) {
    final labels = ['Smile', 'Eyes Closed', 'Eyes Open'];
    return SizedBox(
      height: 390,
      child: GridView.builder(
        scrollDirection: Axis.vertical,
        itemCount: imagePaths.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 2,
          childAspectRatio: 0.95,
        ),
        itemBuilder: (context, index) {
          final imagePath = imagePaths[index];
          final label = index < labels.length
              ? labels[index]
              : 'Image ${index + 1}';

          return Container(
            width: 150,
            margin: const EdgeInsets.only(right: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Container(
                    clipBehavior: Clip.hardEdge,

                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image.file(
                        File(imagePath),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: Icon(
                                Icons.error,
                                color: Colors.red,
                                size: 40,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _startFaceVerification() async {
    final result = await FaceVerification.showVerificationPage(
      context,
      timeoutPerStep: 1000000,
      // TODO 1000000 is just for testing, set a reasonable timeout in production 10
      showFaceLandmarks: true,
      showDebugInfo: true,
      onStepChanged: (step) {
        print('Step changed: ${step.name}');
      },
      onFaceDetected: (faceData) {
        print('Face detected: ${faceData.toString()}');
      },
      onError: (error) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $error')));
      },
    );

    if (result != null) {
      setState(() {
        _lastResult = result;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.success
                ? 'Verification completed successfully!'
                : 'Verification failed: ${result.errorMessage}',
          ),
          backgroundColor: result.success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  void _startFaceVerificationModal() async {
    final result = await FaceVerification.showVerificationModal(
      context,
      timeoutPerStep: 8,
      height: 0.85,
      showFaceLandmarks: true,
      showDebugInfo: true,
      onStepChanged: (step) {
        print('Modal step changed: ${step.name}');
      },
    );

    if (result != null) {
      setState(() {
        _lastResult = result;
      });
    }
  }

  void _startCustomVerification() async {
    final customConfig = FaceVerificationConfig(
      timeoutPerStep: 15,
      smileThreshold: 0.8,
      eyeOpenThreshold: 0.6,
      eyeClosedThreshold: 0.2,
      saveImages: true,
      imageQuality: 0.95,
      numberOfImages: 5,
    );

    final result = await FaceVerification.showVerificationPage(
      context,
      config: customConfig,
      primaryColor: Colors.purple,
      backgroundColor: Colors.black87,
      showFaceLandmarks: true,
      showDebugInfo: true,
      onStepChanged: (step) {
        print('Custom verification step: ${step.name}');
      },
    );

    if (result != null) {
      setState(() {
        _lastResult = result;
      });
    }
  }
}

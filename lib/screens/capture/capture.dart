import 'dart:typed_data';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sighttrack_app/aws/storage.dart';
import 'package:sighttrack_app/models/photo_marker.dart';
import 'package:sighttrack_app/screens/capture/review_capture.dart';
import 'package:sighttrack_app/util/error_message.dart';

class CaptureScreenHandler extends StatefulWidget {
  const CaptureScreenHandler({super.key, this.camera});

  final CameraDescription? camera;

  @override
  State<CaptureScreenHandler> createState() => _CaptureScreenHandlerState();
}

class _CaptureScreenHandlerState extends State<CaptureScreenHandler> {
  @override
  Widget build(BuildContext context) {
    return widget.camera == null
        ? Scaffold(
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.warning, color: Colors.white, size: 150),
                  SizedBox(height: 10),
                  Text(
                    'No camera found',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  Text(
                    'Assuming in emulator and debug mode',
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 30),
                  Text(
                    'If this is not the case, please contact support',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            backgroundColor: Colors.black,
          )
        : CaptureScreen(camera: widget.camera!);
  }
}

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key, required this.camera});

  final CameraDescription camera;

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  late CameraController controller;
  late Future<void> initializeControllerFuture;
  late List<dynamic>? labels;
  bool isLoading = false;
  bool isFrozen = false;

  void initializeCamera() {
    controller = CameraController(widget.camera, ResolutionPreset.high);
    initializeControllerFuture = controller.initialize();
  }

  void onCapture() async {
    if (controller.value.isStreamingImages) {
      await controller.stopImageStream();
    }

    setState(() {
      isLoading = true;
      isFrozen = true;
    });

    try {
      await initializeControllerFuture;
      final XFile image = await controller.takePicture();
      Uint8List imageBytes = await image.readAsBytes();

      // Step 1: Get presigned URL to upload imamge
      final presignedData = await getPresignedURL();

      // Step 2: Upload image to S3
      List<dynamic>? temp = await uploadImageToS3(presignedData, imageBytes);

      setState(() {
        labels = temp;
        isLoading = false; // Hide loading screen
        isFrozen = false; // Unfreeze the camera preview
      });

      if (!mounted) return;

      if (labels == null) {
        showErrorMessage(context, "Bad photo, try again!");
      } else {
        String? username;
        final usernameFuture = Amplify.Auth.getCurrentUser();
        usernameFuture.then((user) {
          username = user.username;
        }).catchError((e) {
          if (!mounted) return;
          showErrorMessage(context, 'Error fetching username: $e');
        });

        // Get user position via Geolocator
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best,
        );

        // Step 3: Create Photomarker object with metadata
        final photoMarker = PhotoMarker(
          photoId: presignedData['object_key'],
          userId: username!,
          time: DateTime.now(),
          latitude: position.latitude,
          longitude: position.longitude,
          imageUrl: presignedData['url'],
        );

        // Step 4 moved to review_upload.dart

        // Step 5: Navigate to review uplaod screen
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReviewCaptureScreen(
              labels: labels!,
              image: image,
              photoMarker: photoMarker,
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        isFrozen = false;
      });
      showErrorMessage(context, 'Error capturing image: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: FutureBuilder<void>(
              future: initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return CameraPreview(controller);
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
          // Capture button in absolute center over the camera preview
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: GestureDetector(
                onTap: onCapture,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade800,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (isLoading) // Show loading overlay when isLoading is true
            Container(
              color: Colors.black45, // Semi-transparent overlay
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}

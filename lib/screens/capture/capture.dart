import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sighttrack_app/aws/s3_helper.dart';
import 'package:sighttrack_app/models/photo_marker.dart';
import 'package:sighttrack_app/screens/capture/review_upload.dart';
import 'package:sighttrack_app/util/error_message.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key, required this.camera});

  final CameraDescription camera;

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  late CameraController controller;
  bool isLoading = false;
  bool isFrozen = false;
  late Future<void> initializeControllerFuture;
  late List<dynamic>? labels;

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
        // Get current user ID from Firebase
        final userId = FirebaseAuth.instance.currentUser?.uid;
        if (userId == null) {
          showErrorMessage(context, "User not logged in.");
          return;
        }

        // Get user position via Geolocator
        Position position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.best,
          ),
        );

        // Step 3: Create Photomarker object with metadata
        final photoMarker = PhotoMarker(
          photoId: presignedData['object_key'],
          userId: userId,
          time: DateTime.now(),
          latitude: position.latitude,
          longitude: position.longitude,
          imageUrl: presignedData['url'],
          label: '',
          // description: 'A photo description',
        );

        // Step 4 moved to review_upload.dart

        // Step 5: Navigate to review uplaod screen
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReviewUploadScreen(
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
      showErrorMessage(context, 'Error capturing imag: $e');
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

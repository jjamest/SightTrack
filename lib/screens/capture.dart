import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:sighttrack_app/util/error_message.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  late CameraController controller;
  late Future<void> initializeControllerFuture;
  late List<CameraDescription> cameras;
  late CameraDescription camera;

  Future<void> initializeCamera() async {
    cameras = await availableCameras();
    camera = cameras.first;
    controller = CameraController(camera, ResolutionPreset.high);
    initializeControllerFuture = controller.initialize();
    setState(() {});
  }

  Future<void> onCaptureImage() async {
    try {
      await initializeControllerFuture;

      final XFile imageFile = await controller.takePicture();
      final Uint8List imageBytes = await imageFile.readAsBytes();
      await uploadImage(imageBytes);
    } catch (e) {
      if (!mounted) return;
      showErrorMessage(context, "Error capturing image: $e");
    }
  }

  Future<void> uploadImage(Uint8List imageBytes) async {
    // Check if the controller is initialized
    if (!controller.value.isInitialized) {
      print('Camera controller is not initialized yet!');
      return;
    }

    try {
      final url = Uri.parse('');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(
          {'image': base64Encode(imageBytes)},
        ),
      );

      if (response.statusCode == 20) {
        print('Image successfully uploaded to backend');
        final data = jsonDecode(response.body);
        print('Response $data');
      } else {
        print('Failed to send image. Status code ${response.statusCode}');
      }
    } on PlatformException catch (e) {
      print('Failedd to upload image: $e');
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
      body: FutureBuilder(
        future: initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return Stack(
              children: <Widget>[
                CameraPreview(controller),
                Positioned(
                  bottom: 30.0,
                  left: 50.0,
                  right: 50.0,
                  child: ClipOval(
                    child: Material(
                      color: Colors.blue,
                      child: InkWell(
                        onTap: onCaptureImage,
                        child: const SizedBox(
                            width: 100.0,
                            height: 100.0,
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 50.0,
                            )),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}

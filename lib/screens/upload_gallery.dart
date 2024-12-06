import 'package:flutter/material.dart';
import 'package:sighttrack_app/aws/dynamo_helper.dart';
import 'package:sighttrack_app/models/photo_marker.dart';

class UploadGalleryScreen extends StatefulWidget {
  const UploadGalleryScreen({super.key});

  @override
  State<UploadGalleryScreen> createState() => _UploadGalleryScreenState();
}

class _UploadGalleryScreenState extends State<UploadGalleryScreen> {
  final List<String> imageUrls = [];

  void initialize() async {
    List<PhotoMarker> photoMarkers = await getMarkersFromAPI();
    for (int i = 0; i < photoMarkers.length; i++) {
      setState(() {
        imageUrls.add(photoMarkers[i].imageUrl);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Recent Uploads"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Number of columns
            crossAxisSpacing: 8.0, // Spacing between columns
            mainAxisSpacing: 8.0, // Spacing between rows
            childAspectRatio: 1.0, // Aspect ratio of grid items
          ),
          itemCount: imageUrls.length,
          itemBuilder: (context, index) {
            return Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.network(
                  imageUrls[index],
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

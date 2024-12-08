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
  bool isLoading = true;

  void initialize() async {
    try {
      // Fetch photo markers from API
      List<PhotoMarker> photoMarkers = await getMarkersFromAPI();

      // Sort photom markers by date
      photoMarkers.sort((a, b) => b.time.compareTo(a.time));

      // Extract URLs
      final urls = photoMarkers.map((marker) => marker.imageUrl).toList();
      if (!mounted) return;
      setState(() {
        imageUrls.addAll(urls);
        isLoading = false; // Mark as loaded
      });
    } catch (e) {
      debugPrint('Error loading images: $e');
      if (!mounted) return;
      setState(() {
        isLoading = false;
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
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator()) // Loading indicator
          : Padding(
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
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            return child; // Image loaded
                          }
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      (loadingProgress.expectedTotalBytes ?? 1)
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(Icons.error, color: Colors.red),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:sighttrack_app/aws/dynamo.dart';
import 'package:sighttrack_app/models/photo_marker.dart';
import 'package:sighttrack_app/screens/upload/upload_view.dart';

class UploadGalleryScreen extends StatefulWidget {
  const UploadGalleryScreen({super.key, this.global = true});

  final bool global;

  @override
  State<UploadGalleryScreen> createState() => _UploadGalleryScreenState();
}

class _UploadGalleryScreenState extends State<UploadGalleryScreen> {
  late List<PhotoMarker> photoMarkers;
  bool isLoading = true;

  void initialize() async {
    try {
      // Fetch photo markers from API
      photoMarkers = await getPhotoMarkers();

      // Sort photo markers by date
      photoMarkers.sort((a, b) => b.time.compareTo(a.time));

      // Get the current user synchronously using async/await
      final user = await Amplify.Auth.getCurrentUser();
      final String username = user.username;

      // Now that you have the username, apply the filter
      List<PhotoMarker> filteredMarkers = widget.global == true
          ? photoMarkers
          : photoMarkers.where((marker) => marker.userId == username).toList();

      if (!mounted) return;
      setState(() {
        photoMarkers = filteredMarkers;
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
        title: Text(
          widget.global ? "Recent Uploads" : "Your Uploads",
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator()) // Loading indicator
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: photoMarkers.isEmpty
                  ? Center(
                      child: const Text(
                        "No uploads yet! Try taking a capture",
                        style: TextStyle(fontSize: 15.0),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // Number of columns
                        crossAxisSpacing: 8.0, // Spacing between columns
                        mainAxisSpacing: 8.0, // Spacing between rows
                        childAspectRatio: 1.0, // Aspect ratio of grid items
                      ),
                      itemCount: photoMarkers.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UploadViewScreen(
                                    photoMarker: photoMarkers[index]),
                              ),
                            );
                          },
                          child: Card(
                            elevation: 4.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12.0),
                              child: Image.network(
                                photoMarkers[index].imageUrl,
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) {
                                    return child; // Image loaded
                                  }
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  (loadingProgress
                                                          .expectedTotalBytes ??
                                                      1)
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
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}

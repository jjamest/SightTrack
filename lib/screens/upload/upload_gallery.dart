import "package:amplify_flutter/amplify_flutter.dart";
import "package:flutter/material.dart";
import "package:sighttrack_app/services/photomarker_service.dart";
import "package:sighttrack_app/models/photomarker.dart";
import "package:sighttrack_app/screens/upload/upload_view.dart";

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
      // Fetch photo markers from API.
      photoMarkers = await getPhotoMarkers();

      // Sort photo markers by date (most recent first).
      photoMarkers.sort((a, b) => b.time.compareTo(a.time));

      // Get the current user.
      final user = await Amplify.Auth.getCurrentUser();
      final String username = user.username;

      // Filter markers if not global.
      List<PhotoMarker> filteredMarkers = widget.global
          ? photoMarkers
          : photoMarkers.where((marker) => marker.userId == username).toList();

      if (!mounted) return;
      setState(() {
        photoMarkers = filteredMarkers;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading images: $e");
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

  Future<void> _refreshGallery() async {
    setState(() {
      isLoading = true;
    });
    initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.global ? "Recent Uploads" : "Your Uploads"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: photoMarkers.isEmpty
                  ? const Center(
                      child: Text(
                        "No uploads yet! Try taking a capture",
                        style: TextStyle(fontSize: 15.0),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: photoMarkers.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () async {
                            final result = await Navigator.push<bool>(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UploadViewScreen(
                                  photoMarker: photoMarkers[index],
                                ),
                              ),
                            );
                            // If result is true (photo was deleted), refresh the gallery.
                            if (result == true) {
                              _refreshGallery();
                            }
                          },
                          child: Card(
                            elevation: 4.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12.0),
                              child: Hero(
                                tag: photoMarkers[index].photoId,
                                child: Image.network(
                                  photoMarkers[index].imageUrl,
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress
                                                    .expectedTotalBytes !=
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
                                      child:
                                          Icon(Icons.error, color: Colors.red),
                                    );
                                  },
                                ),
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

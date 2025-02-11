import "package:amplify_flutter/amplify_flutter.dart";
import "package:flutter/foundation.dart";
import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:geolocator/geolocator.dart";
import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:intl/intl.dart";
import "package:permission_handler/permission_handler.dart";
import "package:provider/provider.dart";
import "package:sighttrack_app/models/photomarker.dart";
import "package:sighttrack_app/models/user_state.dart";
import "package:sighttrack_app/screens/moderator/report_upload.dart";
import "package:sighttrack_app/services/photomarker_service.dart";
import "package:sighttrack_app/widgets/comments.dart";
import "package:sighttrack_app/util/error_message.dart";

class UploadViewScreen extends StatefulWidget {
  const UploadViewScreen({super.key, required this.photoMarker});

  final PhotoMarker photoMarker;

  @override
  State<UploadViewScreen> createState() => _UploadViewScreenState();
}

class _UploadViewScreenState extends State<UploadViewScreen> {
  late GoogleMapController mapController;
  late LatLng currentLocation;
  final usernameFuture = Amplify.Auth.getCurrentUser();
  String username = "";

  Future<void> getLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      openAppSettings();
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
    LatLng location = LatLng(position.latitude, position.longitude);

    if (!mounted) return;
    setState(() {
      currentLocation = location;
    });
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void initialize() async {
    await getLocation();
    usernameFuture.then((user) {
      setState(() {
        username = user.username;
      });
    }).catchError((e) {
      if (!mounted) return;
      showErrorMessage(context, "Error fetching username: $e");
    });
  }

  @override
  void initState() {
    super.initState();
    initialize();
  }

  /// Opens a confirmation dialog before deleting the photo.
  Future<void> _confirmDelete() async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Deletion"),
        content: const Text("Are you sure you want to delete this photo?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != null && confirmed) {
      try {
        await deletePhotoMarker(photoId: widget.photoMarker.photoId);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Photo deleted successfully.")),
        );
        // Pop this screen and return true to indicate deletion.
        Navigator.of(context).pop(true);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete photo: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userState = Provider.of<UserState>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("View Upload"),
        actions: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.flag, color: Colors.red),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ReportUploadScreen(photoMarker: widget.photoMarker),
                    ),
                  );
                },
              ),
              const SizedBox(width: 10),
            ],
          ),
          if (userState.roles.contains("Admin"))
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: _confirmDelete,
                ),
                const SizedBox(width: 10),
              ],
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "DESCRIPTION",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.photoMarker.description!.isEmpty
                              ? "Unavailable"
                              : widget.photoMarker.description!,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 25),
                        Text(
                          "LABEL",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.photoMarker.label!.isEmpty
                              ? "Unavailable"
                              : widget.photoMarker.label!,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 25),
                        Text(
                          "DATE",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat("yyyy-MM-dd")
                              .format(widget.photoMarker.time.toLocal()),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 25),
                        Text(
                          "UPLOADED BY",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.photoMarker.userId,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 25),
                        Image.network(widget.photoMarker.imageUrl),
                        const SizedBox(height: 25),
                        CommentsWidget(
                          photoId: widget.photoMarker.photoId,
                          currentUser: username,
                        ),
                        const SizedBox(height: 25),
                        const Divider(),
                        const SizedBox(height: 25),
                        Center(
                          child: Text(
                            "MORE INFORMATION",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                              letterSpacing: 1.0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Center(
                          child: Text(
                            "Photo ID: ${widget.photoMarker.photoId}",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                              letterSpacing: 1.0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 25),
                        SizedBox(
                          height: 400,
                          width: double.infinity,
                          child: GoogleMap(
                            key:
                                UniqueKey(), // Prevents re-creation issues on iOS
                            onMapCreated: onMapCreated,
                            initialCameraPosition: CameraPosition(
                              target: LatLng(
                                widget.photoMarker.latitude,
                                widget.photoMarker.longitude,
                              ),
                              zoom: 5.0,
                            ),
                            mapType: MapType.satellite,
                            markers: {
                              Marker(
                                markerId: MarkerId(widget.photoMarker.photoId),
                                position: LatLng(
                                  widget.photoMarker.latitude,
                                  widget.photoMarker.longitude,
                                ),
                              ),
                            },
                            compassEnabled: false,
                            myLocationButtonEnabled: false,
                            gestureRecognizers: {
                              Factory<OneSequenceGestureRecognizer>(
                                () => EagerGestureRecognizer(),
                              ),
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

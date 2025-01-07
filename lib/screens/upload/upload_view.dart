import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sighttrack_app/models/photomarker.dart';
import 'package:sighttrack_app/widgets/comments_widget.dart';
import 'package:sighttrack_app/util/error_message.dart';

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
  String username = '';

  Future<void> getLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are permanently denied, handle this by guiding the user to app settings.
      openAppSettings();
      return;
    }

    // If permissions are granted, get the current location.
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
    double lat = position.latitude;
    double long = position.longitude;
    LatLng location = LatLng(lat, long);

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

    // Get the current user for adding comments
    usernameFuture.then((user) {
      setState(() {
        username = user.username;
      });
    }).catchError((e) {
      if (!mounted) return;
      showErrorMessage(context, 'Error fetching username: $e');
    });
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
        title: const Text("View upload"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
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
                          'DESCRIPTION',
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
                              ? 'Unavailable'
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
                          'LABEL',
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
                              ? 'Unavailable'
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
                          'DATE',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('yyyy-MM-dd')
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
                          'UPLOADED BY',
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
                        Divider(),
                        const SizedBox(height: 25),
                        Center(
                          child: Text(
                            'MORE INFORMATION',
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
                            'Photo ID: ${widget.photoMarker.photoId}',
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
                              )
                            },
                            compassEnabled: false,
                            myLocationButtonEnabled: false,
                            // Add gestureRecognizers to ensure the map can handle pan/zoom gestures:
                            gestureRecognizers: {
                              Factory<OneSequenceGestureRecognizer>(
                                  () => EagerGestureRecognizer()),
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

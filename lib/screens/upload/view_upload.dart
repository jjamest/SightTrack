import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sighttrack_app/components/button.dart';
import 'package:sighttrack_app/models/photo_marker.dart';

class ViewUploadScreen extends StatefulWidget {
  const ViewUploadScreen({super.key, required this.photoMarker});

  final PhotoMarker photoMarker;

  @override
  State<ViewUploadScreen> createState() => _ViewUploadScreenState();
}

class _ViewUploadScreenState extends State<ViewUploadScreen> {
  late GoogleMapController mapController;
  late LatLng currentLocation;

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
                      const SizedBox(height: 35),
                      CustomButton(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          label: "Close"),
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
    );
  }
}

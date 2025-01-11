import "dart:math" as math;

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:geolocator/geolocator.dart";
import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:permission_handler/permission_handler.dart";
import "package:sighttrack_app/logging.dart";
import "package:sighttrack_app/services/photomarker_service.dart";
import "package:sighttrack_app/models/photomarker.dart";
import "package:sighttrack_app/navigation_bar.dart";
import "package:sighttrack_app/screens/upload/upload_gallery.dart";
import "package:sighttrack_app/screens/upload/upload_view.dart";
import "package:sighttrack_app/util/graphics.dart";

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  late LatLng currentLocation;
  bool isLoading = true;
  Set<Marker> markers = {};

  Future<void> getLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, display an alert to the user.
        if (!mounted) return;
        setState(() {
          isLoading = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are permanently denied, handle this by guiding the user to app settings.
      openAppSettings();

      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
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
      isLoading = false;
    });
  }

  Future<void> loadMarkers() async {
    try {
      List<PhotoMarker> photoMarkers = await getPhotoMarkers();
      if (!mounted) return;
      setState(() {
        isLoading = true;
      });

      final Uint8List? icon = await getBytesFromAsset("assets/marker.png", 48);

      const double gridSize = 0.0005; // Grid size in latitude/longitude degrees
      const double maxOffset = 0.00015; // Maximum random offset in degrees

      // Create a map to track markers in the same grid cell
      Map<String, List<PhotoMarker>> gridMap = {};

      // Group markers by grid cells
      for (var marker in photoMarkers) {
        String gridKey =
            getGridKey(marker.latitude, marker.longitude, gridSize);
        gridMap.putIfAbsent(gridKey, () => []).add(marker);
      }

      // Random number generator
      final math.Random random = math.Random();

      // Adjust markers within each grid cell
      Set<Marker> newMarkers = {};
      for (var gridMarkers in gridMap.values) {
        for (int i = 0; i < gridMarkers.length; i++) {
          PhotoMarker marker = gridMarkers[i];

          // Apply random offsets to distribute markers within the grid cell
          double randomLatOffset = (random.nextDouble() * 2 - 1) *
              maxOffset; // Random between -maxOffset and +maxOffset
          double randomLngOffset = (random.nextDouble() * 2 - 1) * maxOffset;

          LatLng adjustedPosition = LatLng(
            marker.latitude + randomLatOffset,
            marker.longitude + randomLngOffset,
          );

          newMarkers.add(
            Marker(
              markerId: MarkerId(marker.photoId),
              position: adjustedPosition,
              icon: BitmapDescriptor.bytes(icon!),
              onTap: () {
                // showMarkerInfo(marker);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UploadViewScreen(photoMarker: marker),
                  ),
                );
              },
            ),
          );
        }
      }

      if (!mounted) return;
      setState(() {
        markers = newMarkers;
      });
    } catch (e) {
      logger.e("Error loading markers: $e");

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CustomNavigationBar()),
      );
    }
  }

  /// Helper function to calculate the grid key based on a position and grid size
  String getGridKey(double latitude, double longitude, double gridSize) {
    int latGrid = (latitude / gridSize).floor();
    int lngGrid = (longitude / gridSize).floor();
    return "$latGrid:$lngGrid";
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void initialize() async {
    // Run all tasks concurrently
    await Future.wait([
      loadMarkers(),
      getLocation(),
    ]);

    // After all tasks are complete
    if (!mounted) return;
    setState(() {
      isLoading = false;
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
      body: Stack(
        children: [
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : GoogleMap(
                  onMapCreated: onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: currentLocation,
                    zoom: 14.0,
                  ),
                  myLocationEnabled: true,
                  compassEnabled: false,
                  markers: markers,
                  mapType: MapType.satellite,
                  myLocationButtonEnabled: false,
                ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              heroTag: "my_location_fab",
              backgroundColor: Colors.teal,
              child: Icon(Icons.my_location, color: Colors.white),
              onPressed: () async {
                // Replace default GoogleMap myLocation button
                mapController.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(
                      target: currentLocation,
                      zoom: 14,
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            top: 50.0,
            left: 20.0,
            child: FloatingActionButton(
              heroTag: "gallery_fab",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UploadGalleryScreen(),
                  ),
                );
              },
              backgroundColor: Colors.teal,
              child: const Icon(
                Icons.image,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

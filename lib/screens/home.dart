import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sighttrack_app/aws/dynamo_helper.dart';
import 'package:sighttrack_app/models/photo_marker.dart';
import 'package:sighttrack_app/screens/upload_gallery.dart';
import 'package:sighttrack_app/util/graphics.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late GoogleMapController mapController;
  late String mapStyle;
  late LatLng currentLocation;
  bool isLoading = true;

  Set<Marker> markers = {};

  final Logger logger = Logger();

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

  Future<void> loadMapStyle() async {
    mapStyle = await rootBundle.loadString('assets/map_style.json');
  }

  void showMarkerInfo(PhotoMarker photoMarker) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          photoMarker.description!.isEmpty
              ? 'Untitled capture'
              : photoMarker.description!,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(photoMarker.imageUrl),
            const SizedBox(height: 8),
            Text(
                'Date: ${DateFormat('yyyy-MM-dd').format(photoMarker.time.toLocal())}'),
            Text('User ID: ${photoMarker.userId}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> loadMarkers() async {
    try {
      List<PhotoMarker> photoMarkers = await getMarkersFromAPI();
      final Uint8List? icon = await getBytesFromAsset('assets/marker.png', 48);

      Set<Marker> newMarkers = photoMarkers.map((photoMarker) {
        return Marker(
          markerId: MarkerId(photoMarker.photoId),
          position: LatLng(photoMarker.latitude, photoMarker.longitude),
          icon: BitmapDescriptor.bytes(icon!),
          onTap: () {
            showMarkerInfo(photoMarker);
          },
        );
      }).toSet();

      if (!mounted) return;
      setState(() {
        markers = newMarkers;
      });
    } catch (e) {
      logger.e('Error loading markers: $e');
      loadMarkers();
    }
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void initialize() async {
    // Run all tasks concurrently
    await Future.wait([
      loadMarkers(),
      getLocation(),
      loadMapStyle(),
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
          Container(
            child: isLoading
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
                    style: mapStyle,
                  ),
          ),
          Positioned(
            top: 50.0, // Adjust for your app bar or safe area
            left: 20.0,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const UploadGalleryScreen()),
                );
              },
              backgroundColor: Colors.teal,
              elevation: 4.0,
              child: const Icon(
                Icons.photo_library,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

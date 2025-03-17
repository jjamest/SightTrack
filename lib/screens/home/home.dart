import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' as geo;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isUserInteracting = false;
  Timer? _interactionTimer;
  MapboxMap? _mapboxMap;

  void onMapCreated(MapboxMap mapboxMap) async {
    _mapboxMap = mapboxMap;

    // Remove watermark and attribution.
    await _mapboxMap!.logo.updateSettings(LogoSettings(enabled: false));
    await _mapboxMap!.attribution
        .updateSettings(AttributionSettings(enabled: false));
    await _mapboxMap!.scaleBar.updateSettings(ScaleBarSettings(enabled: false));

    // Enable location component with duck and heading.
    await _mapboxMap!.location.updateSettings(
      LocationComponentSettings(
        enabled: true,
        pulsingEnabled: true,
        puckBearingEnabled: true,
        locationPuck: LocationPuck(
          locationPuck3D: LocationPuck3D(
            modelUri:
                'https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Models/master/2.0/Duck/glTF-Embedded/Duck.gltf',
            modelScale: [30.0, 30.0, 30.0],
          ),
        ),
      ),
    );

    // Center the map on the user's current location.
    try {
      final geo.Position pos = await _determinePosition();
      await _mapboxMap!.setCamera(
        CameraOptions(
          center: Point(coordinates: Position(pos.longitude, pos.latitude)),
          zoom: 10.0,
          bearing: pos.heading,
        ),
      );
    } catch (e) {
      debugPrint('Error getting user location: $e');
    }

    // Listen to location updates and update the camera if the user is not interacting.
    geo.Geolocator.getPositionStream(
      locationSettings: geo.LocationSettings(
        accuracy: geo.LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((position) async {
      if (!_isUserInteracting && _mapboxMap != null) {
        await _mapboxMap!.flyTo(
          CameraOptions(
            center: Point(
                coordinates: Position(position.longitude, position.latitude)),
            bearing: position.heading,
          ),
          MapAnimationOptions(duration: 500),
        );
      }
    });
  }

  Future<geo.Position> _determinePosition() async {
    bool serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    geo.LocationPermission permission = await geo.Geolocator.checkPermission();
    if (permission == geo.LocationPermission.denied) {
      permission = await geo.Geolocator.requestPermission();
      if (permission == geo.LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }

    if (permission == geo.LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    }

    return await geo.Geolocator.getCurrentPosition();
  }

  // Called when the user touches the map.
  void _onUserInteraction() {
    _isUserInteracting = true;
    _interactionTimer?.cancel();
    _interactionTimer = Timer(const Duration(seconds: 2), () {
      setState(() {
        _isUserInteracting = false;
      });
    });
  }

  // Reset camera to current location.
  Future<void> _resetCameraToUserLocation() async {
    try {
      final geo.Position pos = await _determinePosition();
      if (_mapboxMap != null) {
        await _mapboxMap!.flyTo(
          CameraOptions(
            center: Point(coordinates: Position(pos.longitude, pos.latitude)),
            zoom: 10.0,
            bearing: pos.heading,
          ),
          MapAnimationOptions(duration: 500),
        );
      }
    } catch (e) {
      debugPrint('Error resetting camera: $e');
    }
  }

  @override
  void dispose() {
    _interactionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Listener(
        onPointerDown: (_) => _onUserInteraction(),
        child: MapWidget(
          styleUri: 'mapbox://styles/jamestt/cm8c8inqm004b01rxat34g28r',
          onMapCreated: onMapCreated,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _resetCameraToUserLocation,
        child: const Icon(Icons.my_location),
      ),
    );
  }
}

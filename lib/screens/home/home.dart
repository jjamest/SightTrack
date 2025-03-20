import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:sighttrack/logging.dart';
import 'package:sighttrack/models/ModelProvider.dart';
import 'package:sighttrack/screens/home/view_sighting.dart';

class AnnotationClickListener extends OnCircleAnnotationClickListener {
  final void Function(CircleAnnotation) onAnnotationClick;

  AnnotationClickListener({required this.onAnnotationClick});

  @override
  void onCircleAnnotationClick(CircleAnnotation annotation) {
    onAnnotationClick(annotation);
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isUserInteracting = false;
  Timer? _interactionTimer;
  MapboxMap? _mapboxMap;
  List<Sighting> _sightings = [];
  CircleAnnotationManager? _circleAnnotationManager;
  bool _mapLoaded = false;
  final Map<String, Sighting> _annotationSightingMap = {};
  late AnnotationClickListener _annotationClickListener;
  bool _isNavigating = false; // Debounce flag

  @override
  void initState() {
    super.initState();
    _annotationClickListener = AnnotationClickListener(
      onAnnotationClick: (annotation) {
        if (_isNavigating) return; // Skip if already navigating
        _isNavigating = true;
        final sighting = _annotationSightingMap[annotation.id];
        if (sighting != null && mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ViewSightingScreen(sighting: sighting),
            ),
          ).then((_) {
            // Reset flag after navigation completes
            _isNavigating = false;
          });
        } else {
          _isNavigating = false; // Reset if no navigation occurs
        }
      },
    );
    _initializeAmplify();
  }

  Future<void> _fetchSightings() async {
    try {
      final subscription = Amplify.DataStore.observeQuery(
        Sighting.classType,
      ).listen((event) {
        final sightings = event.items;
        if (mounted) {
          setState(() => _sightings = sightings);
          if (_mapLoaded) _addSightingsToMap();
        }
      });

      subscription.onDone(() => Log.i('Sightings subscription closed'));
    } catch (e) {
      Log.e('Fetch error: $e');
    }
  }

  Future<void> _addSightingsToMap() async {
    if (_mapboxMap == null || _circleAnnotationManager == null) return;

    await _circleAnnotationManager!.deleteAll();
    _annotationSightingMap.clear();

    final options = <CircleAnnotationOptions>[];
    for (final sighting in _sightings) {
      options.add(
        CircleAnnotationOptions(
          geometry: Point(
            coordinates: Position(sighting.longitude, sighting.latitude),
          ),
          circleRadius: 10,
          circleColor:
              Color.fromARGB(
                255,
                Random().nextInt(256),
                Random().nextInt(256),
                Random().nextInt(256),
              ).toARGB32(),
          circleBlur: 0.5,
        ),
      );
    }

    final createdAnnotations = await _circleAnnotationManager!.createMulti(
      options,
    );

    for (int i = 0; i < createdAnnotations.length; i++) {
      _annotationSightingMap[createdAnnotations[i]!.id] = _sightings[i];
    }
  }

  void onMapCreated(MapboxMap mapboxMap) async {
    _mapboxMap = mapboxMap;

    await _mapboxMap!.logo.updateSettings(LogoSettings(enabled: false));
    await _mapboxMap!.attribution.updateSettings(
      AttributionSettings(enabled: false),
    );
    await _mapboxMap!.scaleBar.updateSettings(ScaleBarSettings(enabled: false));

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

    try {
      final geo.Position pos = await _determinePosition();
      await _mapboxMap!.setCamera(
        CameraOptions(
          center: Point(coordinates: Position(pos.longitude, pos.latitude)),
          zoom: 1.0,
          bearing: pos.heading,
        ),
      );
    } catch (e) {
      debugPrint('Error getting user location: $e');
    }

    geo.Geolocator.getPositionStream(
      locationSettings: const geo.LocationSettings(
        accuracy: geo.LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((position) async {
      if (!_isUserInteracting && _mapboxMap != null) {
        await _mapboxMap!.flyTo(
          CameraOptions(
            center: Point(
              coordinates: Position(position.longitude, position.latitude),
            ),
            bearing: position.heading,
          ),
          MapAnimationOptions(duration: 500),
        );
      }
    });

    _circleAnnotationManager =
        await _mapboxMap!.annotations.createCircleAnnotationManager();
    _circleAnnotationManager!.addOnCircleAnnotationClickListener(
      _annotationClickListener,
    );
    _mapLoaded = true;
    _addSightingsToMap();
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

  void _onUserInteraction() {
    _isUserInteracting = true;
    _interactionTimer?.cancel();
    _interactionTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isUserInteracting = false);
      }
    });
  }

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

  Future<void> _initializeAmplify() async {
    try {
      await Amplify.DataStore.stop();
      await Amplify.DataStore.start();
      Amplify.DataStore.observe(Sighting.classType).listen((event) {
        _fetchSightings();
      });
      _fetchSightings();
    } catch (e) {
      Log.e('Amplify initialization error: $e');
    }
  }

  @override
  void dispose() {
    _interactionTimer?.cancel();
    _circleAnnotationManager?.deleteAll();
    _circleAnnotationManager = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Listener(
            onPointerDown: (_) => _onUserInteraction(),
            child: MapWidget(
              styleUri: 'mapbox://styles/jamestt/cm8c8inqm004b01rxat34g28r',
              onMapCreated: onMapCreated,
            ),
          ),
          // New top-left button with same styling
          Positioned(
            top: 50.0,
            left: 16.0,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, '/allSightings');
              },
              backgroundColor: Colors.grey[850]!.withValues(alpha: 0.9),
              foregroundColor: Colors.white,
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
                side: BorderSide(
                  color: Colors.grey[700]!.withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
              splashColor: Colors.blueAccent.withValues(alpha: 0.2),
              heroTag: 'topLeftFAB',
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.list,
                  size: 24,
                  color: Colors.white,
                ), // Change icon as needed
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _resetCameraToUserLocation,
        backgroundColor: Colors.grey[850]!.withValues(alpha: 0.9),
        foregroundColor: Colors.white,
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          side: BorderSide(
            color: Colors.grey[700]!.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        splashColor: Colors.blueAccent.withValues(alpha: 0.2),
        heroTag: 'locationFAB',
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(Icons.my_location, size: 24, color: Colors.white),
        ),
      ),
    );
  }
}

extension ColorExtension on Color {
  int toARGB32() {
    // ignore: deprecated_member_use
    return (alpha << 24) | (red << 16) | (green << 8) | blue;
  }
}

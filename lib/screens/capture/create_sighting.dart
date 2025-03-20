import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:sighttrack/logging.dart';
import 'package:sighttrack/models/Sighting.dart';
import 'package:sighttrack/models/User.dart';

class CreateSightingScreen extends StatefulWidget {
  final String imagePath;

  const CreateSightingScreen({super.key, required this.imagePath});

  @override
  State<CreateSightingScreen> createState() => _CreateSightingScreenState();
}

class _CreateSightingScreenState extends State<CreateSightingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  DateTime _selectedDateTime = DateTime.now();
  geo.Position? _selectedLocation;
  String? _selectedSpecies;
  List<String>? identifiedSpecies;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _initializerWrapper();
  }

  Future<void> _initializerWrapper() async {
    List<String>? temp = await _invokeLambdaForSpecies(widget.imagePath);
    if (temp != null && temp.isNotEmpty) {
      setState(() {
        identifiedSpecies = temp;
        _selectedSpecies = temp[0];
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      geo.Position position = await _determinePosition();
      setState(() {
        _selectedLocation = position;
        Log.i(
          'Initial location set: ${_selectedLocation!.latitude}, ${_selectedLocation!.longitude}',
        );
      });
    } catch (e) {
      Log.e('Error getting location: $e');
    }
  }

  Future<List<String>>? _invokeLambdaForSpecies(String imagePath) async {
    try {
      // Read the image file as bytes
      final imageFile = File(imagePath);
      final imageBytes = await imageFile.readAsBytes();

      // Optionally encode as base64 (simpler for JSON payloads)
      final base64Image = base64Encode(imageBytes);
      final requestBody = jsonEncode({'image': base64Image});

      // Send POST request with image data
      final response =
          await Amplify.API
              .post(
                '/analyze',
                body: HttpPayload.json(requestBody),
                headers: {'Content-Type': 'application/json'},
              )
              .response;

      final responseBody = jsonDecode(response.decodeBody());
      final labels =
          (responseBody['labels'] as List)
              .map((label) => label['Name'] as String)
              .toList();

      Log.i('Lambda response: $labels');
      return labels;
    } on ApiException catch (e) {
      Log.e('API call to /analyze failed (method: POST): $e');
      return [];
    } catch (e) {
      Log.e('Unexpected error in Lambda invocation: $e');
      return [];
    }
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

    return await geo.Geolocator.getCurrentPosition(
      locationSettings: geo.LocationSettings(
        accuracy: geo.LocationAccuracy.best,
      ),
    );
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate == null) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      // ignore: use_build_context_synchronously
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );
    if (pickedTime == null) return;

    setState(() {
      _selectedDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  Future<void> _saveSighting() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Get the current authenticated user
        final authUser = await Amplify.Auth.getCurrentUser();
        final userId = authUser.userId; // Cognito User ID
        Log.i('Current user ID: $userId');

        // Query for the User record in DataStore
        final users = await Amplify.DataStore.query(
          User.classType,
          where: User.ID.eq(userId),
        );

        if (users.isEmpty) {
          throw Exception('User not found in DataStore');
        }
        User currentUser = users.first;
        Log.i('Found existing user: ${currentUser.id}');

        // Generate a unique ID for the Sighting (this will also be the S3 key)
        final sightingId = UUID.getUUID(); // Use a UUID generator
        final fileExtension = widget.imagePath.split('.').last; // e.g., 'jpg'
        final s3Key = 'photos/$sightingId.$fileExtension';

        // Upload the image to S3
        Amplify.Storage.uploadFile(
          localFile: AWSFile.fromPath(widget.imagePath),
          path: StoragePath.fromString(s3Key),
          onProgress: (progress) {
            Log.i('Upload progress: ${progress.fractionCompleted}');
          },
        );
        Log.i('Image uploaded to S3 with key: $s3Key');

        // Create the Sighting object with the S3 path
        final sighting = Sighting(
          id: sightingId, // Explicitly set the ID to match the S3 key
          species: _selectedSpecies!,
          photo: s3Key,
          latitude: _selectedLocation!.latitude,
          longitude: _selectedLocation!.longitude,
          timestamp: TemporalDateTime(_selectedDateTime),
          description: _descriptionController.text,
          user: currentUser,
        );

        // Save to DataStore
        await Amplify.DataStore.save(sighting);
        Log.i(
          'Sighting saved. ID: $sightingId | Image Path: $s3Key | Species: ${_selectedSpecies!} | Description: ${_descriptionController.text} | DateTime: ${_selectedDateTime.toIso8601String()} | Location: ${_selectedLocation?.latitude}, ${_selectedLocation?.longitude} | User: ${currentUser.id}',
        );

        if (!mounted) return;
        Navigator.popUntil(context, (route) => route.isFirst);
      } catch (e) {
        Log.e('Error saving sighting: $e');
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error saving sighting: $e')));
        }
      }
    }
  }

  Future<void> _openMapPicker(BuildContext context) async {
    final geo.Position? newLocation = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => MapPickerScreen(initialPosition: _selectedLocation),
      ),
    );
    if (newLocation != null) {
      Log.i(
        'New location from picker: ${newLocation.latitude}, ${newLocation.longitude}',
      );
      setState(() {
        _selectedLocation = newLocation;
      });
    } else {
      Log.w('No new location returned from picker');
    }
  }

  @override
  void dispose() {
    // _speciesController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Sighting'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    showDialog<void>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Sighting Photo'),
                          content: Image.file(
                            File(widget.imagePath),
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.error,
                                      color: Colors.red,
                                      size: 48,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Error loading image',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('Close'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(widget.imagePath),
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.error,
                                  color: Colors.red,
                                  size: 48,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Error loading image',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                DropdownButtonFormField<String>(
                  value: _selectedSpecies,
                  decoration: InputDecoration(
                    labelText: 'Species*',
                    labelStyle: const TextStyle(color: Colors.white),
                    filled: true,
                    fillColor: Colors.grey[850],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.greenAccent,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 12,
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  dropdownColor: Colors.grey[850],
                  items:
                      identifiedSpecies?.map((String species) {
                        return DropdownMenuItem<String>(
                          value: species,
                          child: Text(species),
                        );
                      }).toList() ??
                      [],
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedSpecies = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a species';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    hintText: 'Provide details about the sighting',
                    labelStyle: const TextStyle(color: Colors.white),
                    hintStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: Colors.grey[850],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.greenAccent,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 12,
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Date & Time*',
                    suffixIcon: const Icon(
                      Icons.calendar_today,
                      color: Colors.white,
                    ),
                    labelStyle: const TextStyle(color: Colors.white),
                    filled: true,
                    fillColor: Colors.grey[850],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.greenAccent,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 12,
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  onTap: () => _selectDateTime(context),
                  controller: TextEditingController(
                    text: DateFormat(
                      'MMMM d, yyyy, h:mm a',
                    ).format(_selectedDateTime),
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => _openMapPicker(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[850],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _selectedLocation != null
                                ? 'Lat: ${_selectedLocation!.latitude.toStringAsFixed(6)}, Lng: ${_selectedLocation!.longitude.toStringAsFixed(6)}'
                                : 'Fetching location...',
                            style: const TextStyle(color: Colors.white),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.map, color: Colors.white),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _saveSighting,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Save', style: TextStyle(fontSize: 16)),
                    ),
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MapPickerScreen extends StatefulWidget {
  final geo.Position? initialPosition;

  const MapPickerScreen({super.key, this.initialPosition});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  MapboxMap? _mapboxMap;
  geo.Position? _selectedPosition;

  @override
  void initState() {
    super.initState();
    _selectedPosition = widget.initialPosition;
    Log.i(
      'MapPickerScreen init with initial: ${_selectedPosition?.latitude}, ${_selectedPosition?.longitude}',
    );
  }

  void _onMapCreated(MapboxMap mapboxMap) async {
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
      ),
    );

    if (_selectedPosition != null) {
      await _mapboxMap!.setCamera(
        CameraOptions(
          center: Point(
            coordinates: Position(
              _selectedPosition!.longitude,
              _selectedPosition!.latitude,
            ),
          ),
          zoom: 15.0,
        ),
      );
      Log.i(
        'Camera set to: ${_selectedPosition!.latitude}, ${_selectedPosition!.longitude}',
      );
    }
  }

  void _onCameraChange(CameraChangedEventData eventData) async {
    if (_mapboxMap != null) {
      final cameraState = await _mapboxMap!.getCameraState();
      setState(() {
        _selectedPosition = geo.Position(
          longitude: cameraState.center.coordinates.lng as double,
          latitude: cameraState.center.coordinates.lat as double,
          timestamp: DateTime.now(),
          accuracy: 0.0,
          altitude: 0.0,
          heading: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
          altitudeAccuracy: 0.0,
          headingAccuracy: 0.0,
        );
        Log.i(
          'Camera changed, new position: ${_selectedPosition!.latitude}, ${_selectedPosition!.longitude}',
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          MapWidget(
            styleUri: 'mapbox://styles/jamestt/cm8c8inqm004b01rxat34g28r',
            onMapCreated: _onMapCreated,
            onCameraChangeListener: _onCameraChange,
            cameraOptions: CameraOptions(
              center: Point(
                coordinates: Position(
                  _selectedPosition?.longitude ?? -122.4194,
                  _selectedPosition?.latitude ?? 37.7749,
                ),
              ),
              zoom: 15.0,
            ),
          ),
          const Center(
            child: Icon(Icons.location_pin, color: Colors.red, size: 40),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () {
                Log.i(
                  'Confirm pressed, returning: ${_selectedPosition?.latitude}, ${_selectedPosition?.longitude}',
                );
                Navigator.pop(context, _selectedPosition);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Confirm Location',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

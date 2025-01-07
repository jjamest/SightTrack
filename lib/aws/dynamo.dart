import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sighttrack_app/logging.dart';
import 'package:sighttrack_app/models/photomarker.dart';
import 'package:sighttrack_app/settings.dart';

Future<void> savePhotoMarker(PhotoMarker photoMarker) async {
  try {
    final requestPayload = {
      'photoId': photoMarker.photoId,
      'userId': photoMarker.userId,
      'time': photoMarker.time.toIso8601String(),
      'latitude': photoMarker.latitude,
      'longitude': photoMarker.longitude,
      'imageUrl': photoMarker.imageUrl,
      'label': photoMarker.label,
      'description': photoMarker.description,
    };

    // Make the POST request to API Gateway
    final response = await http.post(
      Uri.parse(ApiConstants.savePhotoMarker),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(requestPayload),
    );

    // Handle the response
    if (response.statusCode == 200) {
      logger.i('Photo marker saved');
    } else {
      logger.e(
          'Error saving metadata: ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    logger.e('Error: $e');
  }
}

Future<List<PhotoMarker>> getPhotoMarkers() async {
  final response = await http.get(Uri.parse(ApiConstants.getPhotoMarkers));

  if (response.statusCode == 200) {
    final List<dynamic> markersData = json.decode(response.body);

    logger.i('Loaded ${markersData.length} markers from API');
    return markersData.map((data) {
      return PhotoMarker.fromMap(data);
    }).toList();
  } else {
    throw Exception('Failed to load photo markers');
  }
}

Future<Map<String, dynamic>> getDataAnalysis() async {
  final response = await http.get(Uri.parse(ApiConstants.getAnalysis));

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load analysis data');
  }
}

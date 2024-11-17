import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sighttrack_app/logging.dart';
import 'package:sighttrack_app/models/photo_marker.dart';

const String saveApiUrl =
    "https://ry9z08o9pd.execute-api.us-east-1.amazonaws.com/prod/savePhotoMetadata";
const String retrieveApiUrl =
    "https://ry9z08o9pd.execute-api.us-east-1.amazonaws.com/prod/getPhotoMarkers";

Future<void> savePhotoMetadata(PhotoMarker photoMarker) async {
  try {
    final requestPayload = {
      'photoId': photoMarker.photoId,
      'userId': photoMarker.userId,
      'time': photoMarker.time.toIso8601String(),
      'location': {
        'latitude': photoMarker.latitude,
        'longitude': photoMarker.longitude,
      },
      'imageUrl': photoMarker.imageUrl,
      'description': photoMarker.description,
    };

    logger.d('Request payload: $requestPayload');

    // Make the POST request to API Gateway
    final response = await http.post(
      Uri.parse(saveApiUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(requestPayload),
    );

    // Handle the response
    if (response.statusCode == 200) {
      logger.i('Metadata saved successfully');
    } else {
      logger.e(
          'Error saving metadata: ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    logger.e('Error: $e');
  }
}

Future<List<PhotoMarker>> getMarkersFromAPI() async {
  final response = await http.get(Uri.parse(retrieveApiUrl));

  if (response.statusCode == 200) {
    final List<dynamic> markersData = json.decode(response.body);
    return markersData.map((data) {
      return PhotoMarker(
        photoId: data['photoId'],
        userId: data['userId'],
        time: DateTime.parse(data['time']),
        latitude: data['location']['latitude'],
        longitude: data['location']['longitude'],
        imageUrl: data['imageUrl'],
        description: data['description'],
      );
    }).toList();
  } else {
    throw Exception('Failed to load photo markers');
  }
}

class PhotoMarker {
  final String photoId;
  final String userId;
  final DateTime time;
  final double latitude;
  final double longitude;
  final String imageUrl;
  final String? description;

  PhotoMarker({
    required this.photoId,
    required this.userId,
    required this.time,
    required this.latitude,
    required this.longitude,
    required this.imageUrl,
    this.description,
  });

  // Convert a PhotoMarker object to a map (used for API requests)
  Map<String, dynamic> toMap() {
    return {
      'photoId': photoId,
      'userId': userId,
      'time': time.toIso8601String(),
      'location': {
        'latitude': latitude,
        'longitude': longitude,
      },
      'imageUrl': imageUrl,
      'description': description,
    };
  }

  // Convert a map (from API response) to a PhotoMarker object
  factory PhotoMarker.fromMap(Map<String, dynamic> map) {
    return PhotoMarker(
      photoId: map['photoId'],
      userId: map['userId'],
      time: DateTime.parse(map['time']),
      latitude: map['location']['latitude'],
      longitude: map['location']['longitude'],
      imageUrl: map['imageUrl'],
      description: map['description'],
    );
  }
}

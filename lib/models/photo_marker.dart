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

  factory PhotoMarker.fromMap(Map<String, dynamic> map) {
    return PhotoMarker(
      photoId: map['photoId'] ?? '',
      userId: map['userId'] ?? '',
      time: DateTime.parse(map['time'] ?? DateTime.now().toIso8601String()),
      latitude: double.parse(map['latitude'].toString()),
      longitude: double.parse(map['longitude'].toString()),
      imageUrl: map['imageUrl'] ?? '', // Now contains the presigned URL
      description: map['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'photoId': photoId,
      'userId': userId,
      'time': time.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'imageUrl': imageUrl,
      'description': description,
    };
  }
}

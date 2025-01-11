import "package:sighttrack_app/models/comment.dart";

class PhotoMarker {
  final String photoId;
  final String userId;
  final DateTime time;
  final double latitude;
  final double longitude;
  final String imageUrl;
  String? label; // Late
  String? description; // Late
  List<Comment> comments;

  PhotoMarker({
    required this.photoId,
    required this.userId,
    required this.time,
    required this.latitude,
    required this.longitude,
    required this.imageUrl,
    this.label,
    this.description,
    this.comments = const [],
  });
  factory PhotoMarker.fromMap(Map<String, dynamic> map) {
    var commentsFromMap = <Comment>[];
    if (map["comments"] != null) {
      commentsFromMap = List<Map<String, dynamic>>.from(map["comments"])
          .map((commentMap) => Comment.fromMap(commentMap))
          .toList();
    }

    return PhotoMarker(
      photoId: map["photoId"] ?? "",
      userId: map["userId"] ?? "",
      time: DateTime.parse(map["time"] ?? DateTime.now().toIso8601String()),
      latitude: double.parse(map["latitude"].toString()),
      longitude: double.parse(map["longitude"].toString()),
      imageUrl: map["imageUrl"] ?? "",
      label: map["label"],
      description: map["description"],
      comments: commentsFromMap,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "photoId": photoId,
      "userId": userId,
      "time": time.toIso8601String(),
      "latitude": latitude,
      "longitude": longitude,
      "imageUrl": imageUrl,
      "label": label,
      "description": description,
      "comments": comments.map((c) => c.toMap()).toList(),
    };
  }
}

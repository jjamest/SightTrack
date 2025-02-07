class AppUser {
  final String username;
  final String status;
  final DateTime createdAt;
  final DateTime lastModifiedAt;
  final Map<String, dynamic> attributes;
  final List<String> groups;

  AppUser({
    required this.username,
    required this.status,
    required this.createdAt,
    required this.lastModifiedAt,
    required this.attributes,
    required this.groups,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      username: map["username"],
      status: map["status"],
      createdAt: DateTime.parse(map["created_at"]),
      lastModifiedAt: DateTime.parse(map["last_modified_at"]),
      attributes: Map<String, dynamic>.from(map["attributes"]),
      groups: List<String>.from(map["groups"]),
    );
  }
}

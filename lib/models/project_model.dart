class Project {
  final String id;
  final String name;
  final String description;
  final String? thumbnail;  // Base64 string
  final List<String> images;  // Base64 strings
  final List<String> videoUrls;
  final String locationName;
  final double latitude;
  final double longitude;
  final DateTime createdAt;
  final DateTime updatedAt;

  Project({
    required this.id,
    required this.name,
    required this.description,
    this.thumbnail,
    required this.images,
    required this.videoUrls,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      thumbnail: map['thumbnail'],
      images: List<String>.from(map['images'] ?? []),
      videoUrls: List<String>.from(map['videoUrls'] ?? []),
      locationName: map['locationName'] ?? 'Unknown location',
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'thumbnail': thumbnail,
      'images': images,
      'videoUrls': videoUrls,
      'locationName': locationName,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // ✅ Add this
  Project copyWith({
    String? id,
    String? name,
    String? description,
    String? thumbnail,
    List<String>? images,
    List<String>? videoUrls,
    String? locationName,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      thumbnail: thumbnail ?? this.thumbnail,
      images: images ?? this.images,
      videoUrls: videoUrls ?? this.videoUrls,
      locationName: locationName ?? this.locationName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class RoomModel {
  final int id;
  final String name;
  final String? description;
  final double latitude;
  final double longitude;
  final int? radiusMeters;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  RoomModel({
    required this.id,
    required this.name,
    this.description,
    required this.latitude,
    required this.longitude,
    this.radiusMeters,
    this.createdAt,
    this.updatedAt,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      radiusMeters: json['radius_meters'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'radius_meters': radiusMeters,
    };
  }
}
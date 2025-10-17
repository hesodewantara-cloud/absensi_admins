class RoomModel {
  final int id;
  final String name;
  final String? description;
  final double latitude;
  final double longitude;
  final int radius;

  RoomModel({
    required this.id,
    required this.name,
    this.description,
    required this.latitude,
    required this.longitude,
    required this.radius,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      radius: json['radius_meters'],
    );
  }
}
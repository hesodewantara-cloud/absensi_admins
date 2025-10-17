class AttendanceModel {
  final int id;
  final String userId;
  final int roomId;
  final String photoUrl;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final String? status;
  final DateTime? createdAt;

  AttendanceModel({
    required this.id,
    required this.userId,
    required this.roomId,
    required this.photoUrl,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.status,
    this.createdAt,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'],
      userId: json['user_id'],
      roomId: json['room_id'],
      photoUrl: json['photo_url'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      timestamp: DateTime.parse(json['timestamp']),
      status: json['status'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'room_id': roomId,
      'photo_url': photoUrl,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
      'status': status,
    };
  }
}
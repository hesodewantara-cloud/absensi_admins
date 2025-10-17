import 'package:absensi_admin/models/room_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RoomService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<RoomModel>> getRooms() async {
    final response = await _supabase.from('rooms').select();
    return (response as List)
        .map((item) => RoomModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> createRoom({
    required String name,
    String? description,
    required double latitude,
    required double longitude,
    required int radius,
  }) async {
    await _supabase.from('rooms').insert({
      'name': name,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'radius_meters': radius,
    });
  }

  Future<void> updateRoom(
    int id, {
    required String name,
    String? description,
    required double latitude,
    required double longitude,
    required int radius,
  }) async {
    await _supabase.from('rooms').update({
      'name': name,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'radius_meters': radius,
    }).eq('id', id);
  }

  Future<void> deleteRoom(int id) async {
    await _supabase.from('rooms').delete().eq('id', id);
  }
}
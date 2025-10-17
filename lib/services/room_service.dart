import 'package:absensi_admin/models/room_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RoomService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<RoomModel>> getRooms() async {
    final response = await _supabase.from('rooms').select();
    final List<dynamic> data = response as List<dynamic>;
    return data.map((e) => RoomModel.fromJson(e)).toList();
  }

  Future<void> addRoom(RoomModel room) async {
    await _supabase.from('rooms').insert({
      'name': room.name,
      'description': room.description,
      'latitude': room.latitude,
      'longitude': room.longitude,
      'radius_meters': room.radiusMeters,
    });
  }

  Future<void> updateRoom(RoomModel room) async {
    await _supabase.from('rooms').update({
      'name': room.name,
      'description': room.description,
      'latitude': room.latitude,
      'longitude': room.longitude,
      'radius_meters': room.radiusMeters,
    }).eq('id', room.id);
  }

  Future<void> deleteRoom(int id) async {
    await _supabase.from('rooms').delete().eq('id', id);
  }
}
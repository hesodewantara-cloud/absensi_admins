import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<Map<String, int>> getDashboardStats() async {
    final totalUsers = await _supabase.from('users').select('id').count();
    final totalRooms = await _supabase.from('rooms').select('id').count();

    final today = DateTime.now().toIso8601String().substring(0, 10);
    final todaysAttendance = await _supabase
        .from('attendance')
        .select('id')
        .gte('timestamp', '$today 00:00:00')
        .lte('timestamp', '$today 23:59:59')
        .count();

    final pendingLeaves = await _supabase
        .from('sick_leaves')
        .select('id')
        .eq('status', 'Menunggu')
        .count();

    return {
      'totalUsers': totalUsers.count,
      'totalRooms': totalRooms.count,
      'todaysAttendance': todaysAttendance.count,
      'pendingLeaves': pendingLeaves.count,
    };
  }

  Future<Map<String, double>> getAttendanceChartData() async {
    // This is a placeholder. In a real app, you'd fetch and aggregate data.
    // For example, count of 'present' vs 'late' vs 'alpha'
    final response = await _supabase.from('attendance').select('status').count();
    return {
      'present': response.count.toDouble(),
      'late': 0, // Placeholder
      'alpha': 0, // Placeholder
    };
  }

  Future<Map<String, double>> getSickLeaveChartData() async {
    final waiting = await _supabase.from('sick_leaves').select().eq('status', 'Menunggu').count();
    final approved = await _supabase.from('sick_leaves').select().eq('status', 'Disetujui').count();
    final rejected = await _supabase.from('sick_leaves').select().eq('status', 'Ditolak').count();

    return {
      'Menunggu': waiting.count.toDouble(),
      'Disetujui': approved.count.toDouble(),
      'Ditolak': rejected.count.toDouble(),
    };
  }
}
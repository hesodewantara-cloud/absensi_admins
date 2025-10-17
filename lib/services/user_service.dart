import 'package:absensi_admin/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<UserModel>> getUsers() async {
    final response = await _supabase.from('users').select();
    final List<dynamic> data = response as List<dynamic>;
    return data.map((e) => UserModel.fromJson(e)).toList();
  }

  Future<void> addUser(UserModel user, String password) async {
    final AuthResponse res = await _supabase.auth.signUp(
      email: user.email,
      password: password,
    );
    if (res.user != null) {
      await _supabase.from('users').update({
        'name': user.name,
        'role': user.role,
        'username': user.username,
      }).eq('id', res.user!.id);
    }
  }

  Future<void> updateUser(UserModel user) async {
    await _supabase.from('users').update({
      'name': user.name,
      'email': user.email,
      'role': user.role,
      'username': user.username,
    }).eq('id', user.id);
  }

  Future<void> deleteUser(String id) async {
    // WARNING: This is an insecure way to delete users and is only used
    // as a workaround for the limitations of the current development environment.
    // In a production application, this logic should be moved to a secure
    // server-side environment (e.g., a Supabase Edge Function) to protect
    // the SERVICE_ROLE key.
    const serviceRoleKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ2dHR1bWh2emRmbGlpbmRhdWJpIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2MDI4OTc5MCwiZXhwIjoyMDc1ODY1NzkwfQ.wTSyxcQYpkkeWFZjjAkbfGIACdQOLHCkMlRf-O-3Y8s';
    final adminAuthClient = SupabaseClient(
      'https://vvttumhvzdfliindaubi.supabase.co',
      serviceRoleKey,
    );

    await adminAuthClient.auth.admin.deleteUser(id);
  }
}
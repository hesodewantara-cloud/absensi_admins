import 'package:absensi_admin/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<UserModel>> getUsers() async {
    final response = await _supabase.from('users').select();
    return (response as List)
        .map((item) => UserModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> createUser({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    final AuthResponse res = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'name': name, 'role': role},
    );
    if (res.user == null) {
      throw Exception('Failed to create user');
    }
  }

  Future<void> updateUser(
    String id, {
    String? name,
    String? email,
    String? role,
    String? password,
  }) async {
    final updates = <String, dynamic>{
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (role != null) 'role': role,
    };

    if (updates.isNotEmpty) {
      await _supabase.from('users').update(updates).eq('id', id);
    }

    if (password != null && password.isNotEmpty) {
      await _supabase.auth.admin.updateUserById(id, attributes: AdminUserAttributes(password: password));
    }
  }

  Future<void> deleteUser(String id) async {
    await _supabase.auth.admin.deleteUser(id);
  }
}
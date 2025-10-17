import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  bool _isAdmin = false;
  bool get isAdmin => _isAdmin;

  Future<bool> signIn(String email, String password) async {
    try {
      final AuthResponse res = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (res.user != null) {
        // Check for admin role
        final user = await _supabase
            .from('users')
            .select('role')
            .eq('id', res.user!.id)
            .single();

        if (user['role'] == 'admin') {
          _isAdmin = true;
          notifyListeners();
          return true;
        }
      }
      return false;
    } catch (e) {
      // Handle error
      return false;
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
    _isAdmin = false;
    notifyListeners();
  }
}
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  bool _isAdmin = false;
  bool get isAdmin => _isAdmin;

  Future<bool> signIn(String email, String password,
      {String? username}) async {
    try {
      String? emailToSignIn = email;
      if (username != null && username.isNotEmpty) {
        final response = await _supabase
            .from('users')
            .select('email')
            .eq('username', username)
            .single();
        emailToSignIn = response['email'];
      }

      if (emailToSignIn == null) {
        return false;
      }

      final AuthResponse res = await _supabase.auth.signInWithPassword(
        email: emailToSignIn,
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
import 'package:absensi_admin/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    // Wait for the widget to be fully mounted
    await Future.delayed(Duration.zero);

    final session = Supabase.instance.client.auth.currentSession;
    if (!mounted) return;

    if (session == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    try {
      final user = await Supabase.instance.client
          .from('users')
          .select('role')
          .eq('id', session.user.id)
          .single();

      if (!mounted) return;

      if (user['role'] == 'admin') {
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        // Log out non-admin users and show access denied
        await Provider.of<AuthService>(context, listen: false).signOut();
        Navigator.pushReplacementNamed(context, '/login', arguments: 'Access Denied. Only admins can log in.');
      }
    } catch (e) {
      // Handle error, e.g., user not found in 'users' table
      await Provider.of<AuthService>(context, listen: false).signOut();
      Navigator.pushReplacementNamed(context, '/login', arguments: 'An error occurred. Please log in again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
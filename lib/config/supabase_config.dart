import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://vvttumhvzdfliindaubi.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ2dHR1bWh2emRmbGlpbmRhdWJpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAyODk3OTAsImV4cCI6MjA3NTg2NTc5MH0.gAum44Q819Y20xw7oGd1eKwfYBKPnruyIBCiuOWYj1g';

  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }
}
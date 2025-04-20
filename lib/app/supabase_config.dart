import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  // Supabase URL and anonymous key
  static const String supabaseUrl = 'https://qgrwnuutybxilkgltxhe.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFncndudXV0eWJ4aWxrZ2x0eGhlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDUxNDY1NjksImV4cCI6MjA2MDcyMjU2OX0.UO60KTX3NU40W6mYg0wZmRz7r5-f5PT0aTLoa106G7g';

  // Supabase client instance
  static final SupabaseClient client = Supabase.instance.client;

  // Initialize Supabase
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      debug: false,
    );
  }
}

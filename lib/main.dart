import 'package:flutter/material.dart';
import 'package:mini_taskhub/app/app.dart';
import 'package:mini_taskhub/app/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await SupabaseConfig.initialize();

  runApp(const App());
}

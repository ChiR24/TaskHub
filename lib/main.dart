import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mini_taskhub/app/app.dart';
import 'package:mini_taskhub/app/supabase_config.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() async {
  // Initialize splash screen
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Supabase
  await SupabaseConfig.initialize();

  // Remove splash screen when initialization is complete
  FlutterNativeSplash.remove();

  runApp(const App());
}

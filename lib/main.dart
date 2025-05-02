import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mini_taskhub/app/app.dart';
import 'package:mini_taskhub/app/supabase_config.dart';
import 'package:mini_taskhub/utils/connectivity_service.dart';
import 'package:mini_taskhub/utils/dns_resolver.dart';
import 'package:mini_taskhub/utils/offline_mode_handler.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() async {
  // Add error handling for the entire app
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('FlutterError: ${details.exception}');
    debugPrint('Stack trace: ${details.stack}');
  };

  // Initialize Flutter binding
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  try {
    // Initialize connectivity service
    ConnectivityService().initialize();

    // Initialize DNS resolver
    await DnsResolver.initialize();

    // Initialize offline mode handler first to ensure it's ready
    await OfflineModeHandler.initialize();
    debugPrint('Offline mode handler initialized successfully');

    // Initialize Supabase with retry logic
    final initialized = await SupabaseConfig.initialize();
    debugPrint('Supabase initialization result: $initialized');

    // If Supabase initialization failed, set offline mode
    if (!initialized) {
      await OfflineModeHandler.setOfflineMode(true);
      debugPrint('Set to offline mode due to initialization failure');
    }
  } catch (e, stackTrace) {
    debugPrint('Error during app initialization: $e');
    debugPrint('Stack trace: $stackTrace');
    // Ensure we're in offline mode if there's any initialization error
    try {
      await OfflineModeHandler.setOfflineMode(true);
      debugPrint('Set to offline mode due to initialization error');
    } catch (e) {
      debugPrint('Failed to set offline mode: $e');
    }
  }

  // Run the app
  runApp(const App());
}

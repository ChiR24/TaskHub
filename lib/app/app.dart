import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:mini_taskhub/app/theme.dart';
import 'package:mini_taskhub/auth/providers/auth_provider.dart';
import 'package:mini_taskhub/screens/login_screen.dart';
import 'package:mini_taskhub/auth/screens/profile_screen.dart';
import 'package:mini_taskhub/auth/screens/signup_screen.dart';
import 'package:mini_taskhub/dashboard/providers/task_provider.dart';
import 'package:mini_taskhub/dashboard/screens/dashboard_screen.dart';
import 'package:mini_taskhub/utils/constants.dart';
import 'package:mini_taskhub/utils/offline_mode_handler.dart';
import 'package:mini_taskhub/widgets/splash_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    // Ensure offline mode handler is initialized
    try {
      if (!OfflineModeHandler.isInitialized) {
        debugPrint('Warning: OfflineModeHandler not initialized in App');
        // We'll continue anyway, as it should have been initialized in main()
      }
    } catch (e) {
      debugPrint('Error checking OfflineModeHandler initialization: $e');
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
      ],
      child: MaterialApp(
        title: 'DayTask',
        theme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
        routes: {
          AppConstants.loginRoute: (context) => const LoginScreen(),
          AppConstants.signupRoute: (context) => const SignupScreen(),
          AppConstants.dashboardRoute: (context) => const DashboardScreen(),
          AppConstants.profileRoute: (context) => const ProfileScreen(),
        },
      ),
    );
  }
}

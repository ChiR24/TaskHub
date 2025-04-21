import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mini_taskhub/app/theme.dart';
import 'package:mini_taskhub/auth/providers/auth_provider.dart';
import 'package:mini_taskhub/auth/screens/login_screen.dart';
import 'package:mini_taskhub/auth/screens/profile_screen.dart';
import 'package:mini_taskhub/auth/screens/signup_screen.dart';
import 'package:mini_taskhub/dashboard/providers/task_provider.dart';
import 'package:mini_taskhub/dashboard/screens/dashboard_screen.dart';
import 'package:mini_taskhub/utils/constants.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
      ],
      child: MaterialApp(
        title: 'DayTask', // Updated app name
        theme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        initialRoute: AppConstants.loginRoute,
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

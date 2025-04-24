import 'package:flutter/foundation.dart';

/// Utility class for platform-specific operations.
class PlatformUtils {
  /// Returns true if the app is running on the web platform.
  static bool get isWeb => kIsWeb;
  
  /// Returns true if the app is running on a mobile platform (Android or iOS).
  static bool get isMobile => !kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);
  
  /// Returns true if the app is running on a desktop platform (Windows, macOS, or Linux).
  static bool get isDesktop => !kIsWeb && (defaultTargetPlatform == TargetPlatform.windows || 
                                          defaultTargetPlatform == TargetPlatform.macOS || 
                                          defaultTargetPlatform == TargetPlatform.linux);
  
  /// Returns the name of the current platform.
  static String get platformName {
    if (kIsWeb) return 'Web';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'Android';
      case TargetPlatform.iOS:
        return 'iOS';
      case TargetPlatform.windows:
        return 'Windows';
      case TargetPlatform.macOS:
        return 'macOS';
      case TargetPlatform.linux:
        return 'Linux';
      default:
        return 'Unknown';
    }
  }
}

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// A platform-agnostic network service that handles network operations
/// in a way that works on all platforms (web, mobile, desktop).
class NetworkService {
  /// Checks if a domain is reachable.
  /// 
  /// This is a platform-agnostic implementation that works on web and native platforms.
  static Future<bool> isDomainReachable(String domain) async {
    try {
      // For web, we can only use HTTP requests to check connectivity
      final response = await http.get(
        Uri.parse('https://$domain'),
      ).timeout(const Duration(seconds: 5));
      
      return response.statusCode < 500; // Any response below 500 means server is responding
    } catch (e) {
      debugPrint('Error checking domain $domain: $e');
      return false;
    }
  }
  
  /// Checks if there is an active internet connection.
  /// 
  /// This is a platform-agnostic implementation that works on web and native platforms.
  static Future<bool> hasInternetConnection() async {
    try {
      // Try multiple domains to ensure we have internet
      final domains = [
        'google.com',
        'cloudflare.com',
        'apple.com',
        'microsoft.com',
        'amazon.com',
      ];
      
      // Try each domain until one succeeds
      for (final domain in domains) {
        try {
          final response = await http.get(
            Uri.parse('https://$domain'),
          ).timeout(const Duration(seconds: 3));
          
          if (response.statusCode < 500) {
            return true;
          }
        } catch (e) {
          debugPrint('Failed to connect to $domain: $e');
          // Continue to the next domain
        }
      }
      
      // If all domains failed, we don't have internet
      return false;
    } catch (e) {
      debugPrint('Error checking internet connection: $e');
      return false;
    }
  }
  
  /// Checks if a specific URL is reachable.
  /// 
  /// This is a platform-agnostic implementation that works on web and native platforms.
  static Future<Map<String, dynamic>> checkUrlStatus(String url) async {
    final result = <String, dynamic>{
      'isReachable': false,
      'statusCode': null,
      'error': null,
    };
    
    try {
      final response = await http.get(
        Uri.parse(url),
      ).timeout(const Duration(seconds: 5));
      
      result['isReachable'] = response.statusCode < 500;
      result['statusCode'] = response.statusCode;
      
      return result;
    } catch (e) {
      result['error'] = e.toString();
      return result;
    }
  }
}

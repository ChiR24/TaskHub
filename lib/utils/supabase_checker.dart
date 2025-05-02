import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mini_taskhub/app/supabase_config.dart';
import 'package:mini_taskhub/utils/platform/network_service.dart';

/// A utility class for checking Supabase project status.
class SupabaseChecker {
  /// Checks if the Supabase project is active by attempting various connection methods.
  static Future<Map<String, dynamic>> checkSupabaseStatus() async {
    final results = <String, dynamic>{
      'isActive': false,
      'dnsResolved': false,
      'httpConnected': false,
      'ipConnected': false,
      'errors': <String>[],
      'suggestions': <String>[],
    };

    // 1. Check domain reachability (platform-agnostic replacement for DNS resolution)
    try {
      final isDomainReachable = await NetworkService.isDomainReachable(SupabaseConfig.supabaseDomain);
      results['dnsResolved'] = isDomainReachable;
      if (isDomainReachable) {
        debugPrint('Domain reachability check successful');
      } else {
        debugPrint('Domain not reachable: ${SupabaseConfig.supabaseDomain}');
      }
    } catch (e) {
      results['errors'].add('Domain reachability check failed: $e');
      debugPrint('Domain reachability check failed: $e');
    }

    // 2. Try HTTP connection to Supabase domain
    try {
      final response = await http.get(
        Uri.parse('https://${SupabaseConfig.supabaseDomain}/rest/v1/?apikey=${SupabaseConfig.supabaseAnonKey}'),
        headers: {
          'apikey': SupabaseConfig.supabaseAnonKey,
        },
      ).timeout(const Duration(seconds: 10));

      results['httpStatus'] = response.statusCode;
      results['httpConnected'] = response.statusCode < 500; // Any response below 500 means server is responding
      debugPrint('HTTP connection status: ${response.statusCode}');

      if (response.statusCode == 200) {
        results['isActive'] = true;
      } else if (response.statusCode == 404) {
        results['suggestions'].add('Supabase project may be deleted or URL is incorrect');
      } else if (response.statusCode == 503) {
        results['suggestions'].add('Supabase project may be paused');
      }
    } catch (e) {
      results['errors'].add('HTTP connection failed: $e');
      debugPrint('HTTP connection failed: $e');
    }

    // 3. Try direct IP connection (using HTTP for web compatibility)
    try {
      final ipStatus = await NetworkService.checkUrlStatus('https://${SupabaseConfig.supabaseIp}');
      results['ipConnected'] = ipStatus['isReachable'] == true;

      if (ipStatus['isReachable'] == true) {
        debugPrint('Direct IP connection successful via HTTP');
      } else {
        debugPrint('Direct IP connection failed: ${ipStatus['error'] ?? 'Unknown error'}');
        results['errors'].add('Direct IP connection failed: ${ipStatus['error'] ?? 'Unknown error'}');
      }
    } catch (e) {
      results['errors'].add('Direct IP connection failed: $e');
      debugPrint('Direct IP connection failed: $e');
    }

    // 4. Check general internet connectivity
    try {
      final hasInternet = await NetworkService.hasInternetConnection();
      results['internetConnected'] = hasInternet;
      debugPrint('Internet connectivity: $hasInternet');
    } catch (e) {
      results['errors'].add('Internet connectivity check failed: $e');
      results['internetConnected'] = false;
      debugPrint('Internet connectivity check failed: $e');
    }

    // Generate suggestions based on results
    if (results['internetConnected'] == false) {
      results['suggestions'].add('No internet connection. Please check your network settings.');
    } else if (results['dnsResolved'] == false && results['internetConnected'] == true) {
      results['suggestions'].add('DNS resolution failed. Try using a different DNS server (e.g., 8.8.8.8).');
    }

    if ((results['errors'] as List<dynamic>).isNotEmpty && results['isActive'] == false) {
      results['suggestions'].add('Verify that your Supabase project is active and not paused/deleted.');
    }

    return results;
  }
}

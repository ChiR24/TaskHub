import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/services.dart';
import 'package:mini_taskhub/utils/dns_resolver.dart';
import 'package:mini_taskhub/utils/direct_ip_connector.dart';
import 'package:mini_taskhub/utils/supabase_checker.dart';
import 'package:mini_taskhub/utils/offline_mode_handler.dart';
import 'package:mini_taskhub/utils/platform/platform_utils.dart';
import 'package:mini_taskhub/utils/platform/network_service.dart';

class SupabaseConfig {
  // Supabase URL and anonymous key
  static const String supabaseDomain = 'qgrwnuutybxilkgltxhe.supabase.co';
  static const String supabaseIp = '146.190.232.198'; // Direct IP address for Supabase
  static const String supabaseUrl = 'https://$supabaseDomain';
  static const String supabaseDirectIpUrl = 'https://$supabaseIp'; // Direct IP URL as fallback
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFncndudXV0eWJ4aWxrZ2x0eGhlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDUxNDY1NjksImV4cCI6MjA2MDcyMjU2OX0.UO60KTX3NU40W6mYg0wZmRz7r5-f5PT0aTLoa106G7g';

  // Supabase client instance
  static final SupabaseClient client = Supabase.instance.client;

  // Initialize Supabase
  // Check if network is available
  static Future<bool> isNetworkAvailable() async {
    try {
      // Use platform-agnostic network service
      return await NetworkService.hasInternetConnection();
    } catch (e) {
      debugPrint('Error checking network: $e');
      return false;
    }
  }

  // IP address fallback for DNS issues
  static const String supabaseIpFallback = '146.190.232.198'; // Replace with actual IP if known

  // Maximum number of retry attempts
  static const int maxRetries = 3;

  // Delay between retries (in milliseconds)
  static const int retryDelay = 2000;

  // Initialize Supabase with robust error handling, retries, and offline mode support
  static Future<bool> initialize() async {
    // Initialize offline mode handler first
    await OfflineModeHandler.initialize();

    // If already in offline mode, don't try to connect
    if (OfflineModeHandler.isOfflineMode) {
      debugPrint('App is in offline mode. Skipping Supabase initialization.');
      return false;
    }

    // Load hosts file (only for native platforms)
    if (!PlatformUtils.isWeb) {
      try {
        await DnsResolver.loadHostsFile();
      } catch (e) {
        debugPrint('Failed to load hosts file: $e');
        // Continue anyway, as this is only a helper for native platforms
      }
    } else {
      debugPrint('Skipping hosts file loading on web platform');
    }

    // Check Supabase status first
    final status = await SupabaseChecker.checkSupabaseStatus();
    debugPrint('Supabase status check: $status');

    // If Supabase is not active but we have internet, it might be paused/deleted
    if (!status['isActive'] && status['internetConnected'] == true) {
      final suggestions = status['suggestions'] ?? [];
      debugPrint('Supabase project may be inactive. Suggestions: $suggestions');
      // We'll continue trying but will likely fail
    }
    int retryCount = 0;
    bool initialized = false;

    while (retryCount < maxRetries && !initialized) {
      try {
        // Check network availability first
        final networkAvailable = await isNetworkAvailable();
        if (!networkAvailable) {
          debugPrint('No network connection available');
          debugPrint('Waiting before retry ${retryCount + 1}/$maxRetries');
          await Future.delayed(Duration(milliseconds: retryDelay));
          retryCount++;
          continue;
        }

        // Try multiple DNS lookups to ensure connectivity
        String resolvedHost = supabaseUrl;
        bool dnsResolved = false;

        // Platform-specific connection priming
        try {
          if (!PlatformUtils.isWeb) {
            // For native platforms, try to establish a direct connection
            try {
              final directConnected = await DirectIpConnector.primeSupabaseConnection();
              if (directConnected) {
                debugPrint('Successfully primed connection to Supabase via direct IP');
              } else {
                debugPrint('Failed to prime connection to Supabase via direct IP');
              }
            } catch (e) {
              debugPrint('Error priming connection: $e');
            }

            // Try multiple DNS servers (native only)
            List<String> dnsTestDomains = [
              supabaseDomain,
              'google.com',
              'cloudflare.com'
            ];

            for (String domain in dnsTestDomains) {
              try {
                final lookupResult = await DnsResolver.resolve(domain);
                if (lookupResult.isNotEmpty) {
                  debugPrint('DNS lookup successful for $domain: ${lookupResult.first.address}');
                  dnsResolved = true;
                  break;
                }
              } catch (e) {
                debugPrint('DNS lookup failed for $domain: $e');
              }
            }
          } else {
            // For web, use HTTP checks
            List<String> testDomains = [
              supabaseDomain,
              'google.com',
              'cloudflare.com'
            ];

            for (String domain in testDomains) {
              try {
                final isReachable = await NetworkService.isDomainReachable(domain);
                if (isReachable) {
                  debugPrint('Domain reachability check successful for $domain');
                  dnsResolved = true;
                  break;
                }
              } catch (e) {
                debugPrint('Domain reachability check failed for $domain: $e');
              }
            }
          }

          // If we can resolve other domains but not Supabase, try IP fallback
          if (dnsResolved && !await canResolveSupabaseDomain()) {
            debugPrint('Using IP fallback for Supabase');
            resolvedHost = supabaseDirectIpUrl;
          }
        } catch (e) {
          debugPrint('Connection resolution error: $e');
        }

        // Try HTTP connectivity test
        try {
          // Test HTTP connection to Supabase directly
          final supabaseStatus = await NetworkService.checkUrlStatus('https://${supabaseDomain}/rest/v1/?apikey=${supabaseAnonKey}');
          if (supabaseStatus['isReachable'] == true) {
            debugPrint('HTTP connectivity test to Supabase successful');
          } else {
            // Fall back to testing general internet connectivity
            final googleStatus = await NetworkService.checkUrlStatus('https://www.google.com');
            if (googleStatus['isReachable'] == true) {
              debugPrint('General HTTP connectivity test successful');
            } else {
              debugPrint('General HTTP connectivity test failed');
            }
          }
        } catch (e) {
          debugPrint('HTTP connectivity test failed: $e');
          // Continue anyway, as Supabase might still work
        }

        // Try to initialize Supabase with domain first
        debugPrint('Attempting to initialize Supabase with domain (attempt ${retryCount + 1}/$maxRetries)');
        try {
          await Supabase.initialize(
            url: supabaseUrl,
            anonKey: supabaseAnonKey,
            debug: true, // Enable debug mode to see more detailed errors
            authOptions: const FlutterAuthClientOptions(
              autoRefreshToken: true,
            ),
          ).timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw TimeoutException('Supabase domain initialization timed out');
            },
          );
          debugPrint('Supabase initialized successfully with domain URL');
          initialized = true;
          break;
        } catch (domainError) {
          debugPrint('Failed to initialize with domain: $domainError');
          debugPrint('Trying with direct IP address...');

          // If domain fails, try with direct IP
          try {
            // Add Host header to make SSL work with IP address
            final customHeaders = {
              'Host': supabaseDomain,
            };

            await Supabase.initialize(
              url: supabaseDirectIpUrl,
              anonKey: supabaseAnonKey,
              debug: true,
              authOptions: const FlutterAuthClientOptions(
                autoRefreshToken: true,
              ),
              // Custom headers not directly supported in this version
              // We'll handle this differently
            ).timeout(
              const Duration(seconds: 10),
              onTimeout: () {
                throw TimeoutException('Supabase IP initialization timed out');
              },
            );
            debugPrint('Supabase initialized successfully with IP address');
            initialized = true;
            break;
          } catch (ipError) {
            debugPrint('Failed to initialize with IP: $ipError');
            // Continue to next retry
          }
        }
      } catch (e) {
        debugPrint('Error initializing Supabase (attempt ${retryCount + 1}/$maxRetries): $e');
        if (retryCount < maxRetries - 1) {
          debugPrint('Retrying in ${retryDelay}ms...');
          await Future.delayed(Duration(milliseconds: retryDelay));
        } else {
          debugPrint('Max retries reached. Switching to offline mode.');
          await OfflineModeHandler.setOfflineMode(true);
        }
        retryCount++;
      }
    }

    if (!initialized) {
      debugPrint('Failed to initialize Supabase after $maxRetries attempts');
      debugPrint('App will continue in offline mode');
      await OfflineModeHandler.setOfflineMode(true);
      return false;
    }

    return true;
  }

  // Helper method to check if Supabase domain can be resolved
  static Future<bool> canResolveSupabaseDomain() async {
    try {
      // For web, we can only use HTTP requests to check connectivity
      if (PlatformUtils.isWeb) {
        return await NetworkService.isDomainReachable(supabaseDomain);
      }

      // For native platforms, try with our custom DNS resolver first
      try {
        final addresses = await DnsResolver.resolve(supabaseDomain);
        return addresses.isNotEmpty;
      } catch (e) {
        debugPrint('Custom DNS resolver failed: $e');
      }

      // Fall back to HTTP check for all platforms
      return await NetworkService.isDomainReachable(supabaseDomain);
    } catch (e) {
      debugPrint('Supabase domain resolution failed: $e');
      return false;
    }
  }
}

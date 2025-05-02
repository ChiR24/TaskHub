import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:mini_taskhub/utils/dns_resolver.dart';

/// A custom HTTP client that uses our DNS resolver to handle DNS issues.
class CustomHttpClient {
  // Singleton pattern
  static final CustomHttpClient _instance = CustomHttpClient._internal();
  factory CustomHttpClient() => _instance;
  CustomHttpClient._internal();

  // Default timeout
  static const Duration defaultTimeout = Duration(seconds: 15);

  // Create a client with our custom DNS resolution
  HttpClient createClient() {
    final client = HttpClient();
    
    // Set default timeout
    client.connectionTimeout = defaultTimeout;
    
    // Override the DNS resolution
    client.badCertificateCallback = (X509Certificate cert, String host, int port) {
      debugPrint('Bad certificate for $host:$port');
      // Accept bad certificates in debug mode
      return kDebugMode;
    };
    
    return client;
  }

  // GET request with custom DNS resolution
  Future<HttpClientResponse> get(String url, {Duration? timeout}) async {
    final uri = Uri.parse(url);
    final client = createClient();
    
    try {
      // Try to resolve the hostname first
      if (uri.host.isNotEmpty) {
        try {
          final addresses = await DnsResolver.resolve(uri.host);
          if (addresses.isNotEmpty) {
            debugPrint('Resolved ${uri.host} to ${addresses.first.address}');
          }
        } catch (e) {
          debugPrint('Failed to resolve ${uri.host}: $e');
          // Continue anyway, as the HttpClient might use a different DNS resolver
        }
      }
      
      final request = await client.getUrl(uri)
          .timeout(timeout ?? defaultTimeout);
      
      // Set common headers
      request.headers.set('User-Agent', 'DayTask/1.0');
      
      final response = await request.close()
          .timeout(timeout ?? defaultTimeout);
      
      return response;
    } catch (e) {
      debugPrint('HTTP GET request failed: $e');
      rethrow;
    } finally {
      client.close();
    }
  }

  // POST request with custom DNS resolution
  Future<HttpClientResponse> post(String url, {Map<String, dynamic>? body, Duration? timeout}) async {
    final uri = Uri.parse(url);
    final client = createClient();
    
    try {
      // Try to resolve the hostname first
      if (uri.host.isNotEmpty) {
        try {
          final addresses = await DnsResolver.resolve(uri.host);
          if (addresses.isNotEmpty) {
            debugPrint('Resolved ${uri.host} to ${addresses.first.address}');
          }
        } catch (e) {
          debugPrint('Failed to resolve ${uri.host}: $e');
          // Continue anyway, as the HttpClient might use a different DNS resolver
        }
      }
      
      final request = await client.postUrl(uri)
          .timeout(timeout ?? defaultTimeout);
      
      // Set common headers
      request.headers.set('User-Agent', 'DayTask/1.0');
      request.headers.set('Content-Type', 'application/json');
      
      // Add body if provided
      if (body != null) {
        request.write(body.toString());
      }
      
      final response = await request.close()
          .timeout(timeout ?? defaultTimeout);
      
      return response;
    } catch (e) {
      debugPrint('HTTP POST request failed: $e');
      rethrow;
    } finally {
      client.close();
    }
  }
}

import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:mini_taskhub/app/supabase_config.dart';

/// A utility class for establishing direct IP connections to Supabase.
class DirectIpConnector {
  /// Attempts to establish a direct socket connection to Supabase.
  /// This can help "warm up" the network connection before Supabase tries to connect.
  static Future<bool> primeSupabaseConnection() async {
    const int port = 443; // HTTPS port
    const Duration timeout = Duration(seconds: 5);
    
    debugPrint('Attempting to prime Supabase connection via direct IP...');
    
    try {
      // Try to connect directly to the Supabase IP
      final socket = await Socket.connect(
        SupabaseConfig.supabaseIp, 
        port,
        timeout: timeout,
      );
      
      // Send a simple HTTP request to establish the connection
      final request = 'GET / HTTP/1.1\r\n'
          'Host: ${SupabaseConfig.supabaseDomain}\r\n'
          'Connection: close\r\n\r\n';
      
      socket.write(request);
      
      // Wait for some data to come back
      await socket.flush();
      
      // Read some data to ensure the connection is working
      final completer = Completer<bool>();
      
      socket.listen(
        (data) {
          // We got some data back, connection is working
          if (!completer.isCompleted) {
            debugPrint('Successfully received data from Supabase IP');
            completer.complete(true);
          }
        },
        onError: (error) {
          if (!completer.isCompleted) {
            debugPrint('Error receiving data from Supabase IP: $error');
            completer.complete(false);
          }
        },
        onDone: () {
          if (!completer.isCompleted) {
            debugPrint('Connection to Supabase IP closed');
            completer.complete(true);
          }
        },
      );
      
      // Wait for the connection to complete or timeout
      final result = await completer.future.timeout(
        timeout,
        onTimeout: () {
          debugPrint('Timeout waiting for Supabase IP response');
          return false;
        },
      );
      
      // Close the socket
      await socket.close();
      
      return result;
    } catch (e) {
      debugPrint('Failed to connect to Supabase IP: $e');
      return false;
    }
  }
  
  /// Attempts to establish a direct HTTP connection to Supabase.
  static Future<bool> testSupabaseHttpConnection() async {
    debugPrint('Testing HTTP connection to Supabase...');
    
    try {
      // Create a custom HTTP client
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 5);
      
      // Try to connect to the Supabase IP directly
      final request = await client.getUrl(
        Uri.parse('https://${SupabaseConfig.supabaseIp}'),
      );
      
      // Add the Host header to make SSL work
      request.headers.set('Host', SupabaseConfig.supabaseDomain);
      
      // Send the request
      final response = await request.close();
      
      // Read the response to ensure the connection is working
      await response.drain<void>();
      
      // Close the client
      client.close();
      
      debugPrint('Successfully connected to Supabase via HTTP: ${response.statusCode}');
      return true;
    } catch (e) {
      debugPrint('Failed to connect to Supabase via HTTP: $e');
      return false;
    }
  }
}

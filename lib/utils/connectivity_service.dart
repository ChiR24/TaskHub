import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:mini_taskhub/utils/dns_resolver.dart';

/// A service for checking and monitoring network connectivity.
class ConnectivityService {
  // Singleton pattern
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  // Stream controller for connectivity status
  final _connectivityController = StreamController<bool>.broadcast();

  // Stream of connectivity status changes
  Stream<bool> get connectivityStream => _connectivityController.stream;

  // Current connectivity status
  bool _isConnected = false;
  bool get isConnected => _isConnected;

  // Timer for periodic connectivity checks
  Timer? _connectivityTimer;

  // Initialize the service
  void initialize() {
    // Check connectivity immediately
    checkConnectivity();

    // Set up periodic connectivity checks
    _connectivityTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      checkConnectivity();
    });
  }

  // Check if the device is connected to the internet
  Future<bool> checkConnectivity() async {
    bool wasConnected = _isConnected;
    _isConnected = await _checkInternetConnectivity();
    
    // Notify listeners if connectivity status changed
    if (wasConnected != _isConnected) {
      _connectivityController.add(_isConnected);
    }
    
    return _isConnected;
  }

  // Internal method to check internet connectivity
  Future<bool> _checkInternetConnectivity() async {
    try {
      // Try multiple approaches to check connectivity
      
      // 1. Try to connect to reliable hosts
      List<String> reliableHosts = [
        'google.com',
        'cloudflare.com',
        'apple.com',
        'microsoft.com',
        'amazon.com',
      ];
      
      for (String host in reliableHosts) {
        try {
          // Try DNS resolution first
          final addresses = await InternetAddress.lookup(host);
          if (addresses.isNotEmpty) {
            debugPrint('Successfully resolved $host');
            
            // Try HTTP connection to verify internet access
            try {
              final httpClient = HttpClient();
              httpClient.connectionTimeout = const Duration(seconds: 5);
              
              final request = await httpClient.getUrl(Uri.parse('https://$host'));
              final response = await request.close();
              await response.drain<void>();
              httpClient.close();
              
              debugPrint('Successfully connected to $host');
              return true;
            } catch (e) {
              debugPrint('Failed to connect to $host: $e');
              // Continue to next host
            }
          }
        } catch (e) {
          debugPrint('Failed to resolve $host: $e');
          // Continue to next host
        }
      }
      
      // 2. Try custom DNS resolver as a last resort
      try {
        final addresses = await DnsResolver.resolve('google.com');
        if (addresses.isNotEmpty) {
          debugPrint('Custom DNS resolver succeeded');
          return true;
        }
      } catch (e) {
        debugPrint('Custom DNS resolver failed: $e');
      }
      
      return false;
    } catch (e) {
      debugPrint('Error checking connectivity: $e');
      return false;
    }
  }

  // Dispose the service
  void dispose() {
    _connectivityTimer?.cancel();
    _connectivityController.close();
  }
}

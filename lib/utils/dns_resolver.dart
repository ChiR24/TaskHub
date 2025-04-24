import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:mini_taskhub/utils/platform/platform_utils.dart';
import 'package:mini_taskhub/utils/platform/network_service.dart';

// Conditionally import dart:io only for non-web platforms
import 'dart:io' if (dart.library.html) 'package:mini_taskhub/utils/platform/web_stub.dart' as io;

/// A custom DNS resolver that provides additional functionality
/// for resolving domain names to IP addresses.
class DnsResolver {
  /// Cache of resolved IP addresses
  static final Map<String, List<io.InternetAddress>> _dnsCache = {};

  /// Custom hosts file entries
  static final Map<String, String> _hostsEntries = {};

  /// DNS servers to try (Google DNS and Cloudflare DNS)
  static const List<String> _dnsServers = [
    '8.8.8.8',     // Google DNS
    '8.8.4.4',     // Google DNS backup
    '1.1.1.1',     // Cloudflare DNS
    '1.0.0.1',     // Cloudflare DNS backup
    '9.9.9.9',     // Quad9 DNS
  ];

  /// Resolve a domain name to IP addresses with fallback DNS servers
  static Future<List<io.InternetAddress>> resolve(String domain) async {
    // Check cache first
    if (_dnsCache.containsKey(domain)) {
      debugPrint('DNS cache hit for $domain: ${_dnsCache[domain]!.map((e) => e.address).join(', ')}');
      return _dnsCache[domain]!;
    }

    // Check hosts file entries
    if (_hostsEntries.containsKey(domain)) {
      final ip = _hostsEntries[domain]!;
      debugPrint('Using hosts file entry for $domain: $ip');
      final address = io.InternetAddress(ip);
      final addresses = [address];
      _dnsCache[domain] = addresses;
      return addresses;
    }

    // Try system DNS first (platform-specific)
    if (!PlatformUtils.isWeb) {
      try {
        final addresses = await io.InternetAddress.lookup(domain);
        if (addresses.isNotEmpty) {
          _dnsCache[domain] = addresses;
          debugPrint('Resolved $domain using system DNS: ${addresses.map((e) => e.address).join(', ')}');
          return addresses;
        }
      } catch (e) {
        debugPrint('System DNS lookup failed for $domain: $e');
      }
    } else {
      // For web, use HTTP to check domain
      try {
        final isReachable = await NetworkService.isDomainReachable(domain);
        if (isReachable) {
          // Create a fake IP address for web
          final address = io.InternetAddress('0.0.0.0'); // Dummy IP for web
          final addresses = [address];
          _dnsCache[domain] = addresses;
          debugPrint('Domain $domain is reachable on web');
          return addresses;
        }
      } catch (e) {
        debugPrint('Web domain check failed for $domain: $e');
      }
    }

    // If system DNS fails, try alternative DNS servers (native platforms only)
    if (!PlatformUtils.isWeb) {
      for (final dnsServer in _dnsServers) {
        try {
          // This is a simplified approach - in a real app, you would need
          // to implement a proper DNS client that can query specific DNS servers
          // For now, we're just checking if we can reach the DNS server
          final dnsServerReachable = await _isDnsServerReachable(dnsServer);
          if (dnsServerReachable) {
            debugPrint('DNS server $dnsServer is reachable');

            // Try system DNS again - sometimes just checking the DNS server
            // can help "wake up" the system DNS
            try {
              final addresses = await io.InternetAddress.lookup(domain);
              if (addresses.isNotEmpty) {
                _dnsCache[domain] = addresses;
                debugPrint('Resolved $domain after DNS server check: ${addresses.map((e) => e.address).join(', ')}');
                return addresses;
              }
            } catch (e) {
              debugPrint('DNS lookup still failed for $domain: $e');
            }
          }
        } catch (e) {
          debugPrint('Failed to check DNS server $dnsServer: $e');
        }
      }
    }

    // Special case for Supabase domain and subdomains
    if (domain.contains('qgrwnuutybxilkgltxhe.supabase.co')) {
      // Hardcoded fallback for Supabase
      const fallbackIp = '146.190.232.198';
      debugPrint('Using hardcoded fallback IP for Supabase domain $domain: $fallbackIp');
      final address = io.InternetAddress(fallbackIp);
      final addresses = [address];
      _dnsCache[domain] = addresses;
      return addresses;
    }

    // If all DNS servers fail, throw an exception
    throw Exception('Failed to resolve $domain using all available DNS servers');
  }

  /// Check if a DNS server is reachable
  static Future<bool> _isDnsServerReachable(String dnsServer) async {
    if (PlatformUtils.isWeb) {
      // Web doesn't support direct socket connections
      return false;
    }

    try {
      final socket = await io.Socket.connect(dnsServer, 53, timeout: const Duration(seconds: 2));
      await socket.close();
      return true;
    } catch (e) {
      debugPrint('DNS server $dnsServer is not reachable: $e');
      return false;
    }
  }

  /// Clear the DNS cache
  static void clearCache() {
    _dnsCache.clear();
    debugPrint('DNS cache cleared');
  }

  /// Get a specific IP address for a domain (if available)
  static Future<String?> getIpAddress(String domain) async {
    try {
      final addresses = await resolve(domain);
      if (addresses.isNotEmpty) {
        return addresses.first.address;
      }
    } catch (e) {
      debugPrint('Failed to get IP address for $domain: $e');
    }
    return null;
  }

  /// Load custom hosts file from assets
  static Future<void> loadHostsFile() async {
    if (PlatformUtils.isWeb) {
      debugPrint('Skipping hosts file loading on web platform');
      return;
    }

    try {
      final String hostsContent = await rootBundle.loadString('assets/hosts');
      final List<String> lines = hostsContent.split('\n');

      for (String line in lines) {
        // Skip comments and empty lines
        if (line.trim().isEmpty || line.trim().startsWith('#')) {
          continue;
        }

        // Parse hosts file entry (IP hostname)
        final parts = line.trim().split(RegExp(r'\s+'));
        if (parts.length >= 2) {
          final ip = parts[0];
          final hostname = parts[1];

          _hostsEntries[hostname] = ip;
          debugPrint('Added hosts entry: $hostname -> $ip');
        }
      }

      debugPrint('Loaded ${_hostsEntries.length} hosts entries');
    } catch (e) {
      debugPrint('Failed to load hosts file: $e');
    }
  }

  /// Initialize the DNS resolver
  static Future<void> initialize() async {
    await loadHostsFile();
  }
}

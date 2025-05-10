import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mini_taskhub/utils/offline_mode_handler.dart';

/// A widget that displays the current connection status.
class ConnectionStatusWidget extends StatefulWidget {
  final bool showOfflineOnly;

  const ConnectionStatusWidget({
    super.key,
    this.showOfflineOnly = false,
  });

  @override
  State<ConnectionStatusWidget> createState() => _ConnectionStatusWidgetState();
}

class _ConnectionStatusWidgetState extends State<ConnectionStatusWidget> {
  bool _isOffline = false;
  bool _isInitialized = false;
  StreamSubscription<bool>? _offlineModeSubscription;

  @override
  void initState() {
    super.initState();
    _initializeOfflineStatus();
  }

  Future<void> _initializeOfflineStatus() async {
    try {
      // Ensure OfflineModeHandler is initialized
      if (!OfflineModeHandler.isInitialized) {
        await OfflineModeHandler.initialize();
      }

      // Get the current offline status
      _isOffline = OfflineModeHandler.isOfflineMode;
      _isInitialized = true;

      // Subscribe to offline mode changes
      _offlineModeSubscription = OfflineModeHandler.offlineModeStream.listen((isOffline) {
        if (mounted) {
          setState(() {
            _isOffline = isOffline;
          });
        }
      });

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Error initializing offline status: $e');
    }
  }

  @override
  void dispose() {
    // Cancel the subscription when the widget is disposed
    _offlineModeSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      // Show a loading indicator or nothing while initializing
      return const SizedBox.shrink();
    }

    if (widget.showOfflineOnly && !_isOffline) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: _isOffline
          ? Colors.red.withOpacity(0.8)
          : Colors.green.withOpacity(0.8),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _isOffline ? Icons.cloud_off : Icons.cloud_done,
            size: 16,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            _isOffline ? 'Offline Mode' : 'Online',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// A widget that displays a banner when the app is in offline mode.
class OfflineBanner extends StatefulWidget {
  final VoidCallback? onRetry;

  const OfflineBanner({
    super.key,
    this.onRetry,
  });

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner> {
  bool _isOffline = false;
  bool _isInitialized = false;
  StreamSubscription<bool>? _offlineModeSubscription;

  @override
  void initState() {
    super.initState();
    _initializeOfflineStatus();
  }

  Future<void> _initializeOfflineStatus() async {
    try {
      // Ensure OfflineModeHandler is initialized
      if (!OfflineModeHandler.isInitialized) {
        await OfflineModeHandler.initialize();
      }

      // Get the current offline status
      _isOffline = OfflineModeHandler.isOfflineMode;
      _isInitialized = true;

      // Subscribe to offline mode changes
      _offlineModeSubscription = OfflineModeHandler.offlineModeStream.listen((isOffline) {
        if (mounted) {
          setState(() {
            _isOffline = isOffline;
          });
        }
      });

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Error initializing offline status: $e');
    }
  }

  @override
  void dispose() {
    // Cancel the subscription when the widget is disposed
    _offlineModeSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      // Show a loading indicator or nothing while initializing
      return const SizedBox.shrink();
    }

    if (!_isOffline) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.red.shade800,
      child: Row(
        children: [
          const Icon(
            Icons.cloud_off,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'You are currently offline. Some features may be limited.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
          if (widget.onRetry != null)
            TextButton(
              onPressed: widget.onRetry,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(60, 24),
                foregroundColor: Colors.white,
                backgroundColor: Colors.red.shade900,
              ),
              child: const Text('Retry'),
            ),
        ],
      ),
    );
  }
}

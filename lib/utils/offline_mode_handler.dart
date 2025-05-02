import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mini_taskhub/models/task.dart';
import 'package:mini_taskhub/utils/supabase_checker.dart';

/// A utility class for handling offline mode and data synchronization.
class OfflineModeHandler {
  /// Stream controller for offline mode changes
  static final StreamController<bool> _offlineModeController = StreamController<bool>.broadcast();

  /// Stream of offline mode changes
  static Stream<bool> get offlineModeStream => _offlineModeController.stream;
  static const String _offlineTasksKey = 'offline_tasks';
  static const String _offlineUserKey = 'offline_user';
  static const String _isOfflineModeKey = 'is_offline_mode';

  static bool _isOfflineMode = false;
  static bool _isInitialized = false;

  /// Returns whether the handler has been initialized.
  static bool get isInitialized => _isInitialized;

  /// Returns whether the app is currently in offline mode.
  static bool get isOfflineMode {
    // Ensure we're initialized
    if (!_isInitialized) {
      debugPrint('Warning: OfflineModeHandler accessed before initialization');
      // Return a default value
      return false;
    }
    return _isOfflineMode;
  }

  /// Initializes the offline mode handler.
  static Future<void> initialize() async {
    if (_isInitialized) return;

    final prefs = await SharedPreferences.getInstance();
    _isOfflineMode = prefs.getBool(_isOfflineModeKey) ?? false;

    _isInitialized = true;

    // Notify listeners of the initial state
    _offlineModeController.add(_isOfflineMode);

    debugPrint('Offline mode initialized: $_isOfflineMode');
  }

  /// Sets the offline mode status.
  static Future<void> setOfflineMode(bool value) async {
    if (_isOfflineMode == value) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isOfflineModeKey, value);
    _isOfflineMode = value;

    // Notify listeners of the change
    _offlineModeController.add(_isOfflineMode);

    debugPrint('Offline mode set to: $_isOfflineMode');
  }

  /// Saves a task to offline storage.
  static Future<void> saveTaskOffline(Task task) async {
    final prefs = await SharedPreferences.getInstance();
    final offlineTasks = prefs.getStringList(_offlineTasksKey) ?? [];

    // Convert task to JSON
    final taskJson = jsonEncode(task.toJson());

    // Check if task already exists
    final existingIndex = offlineTasks.indexWhere((t) {
      final decoded = jsonDecode(t);
      return decoded['id'] == task.id;
    });

    if (existingIndex >= 0) {
      // Update existing task
      offlineTasks[existingIndex] = taskJson;
    } else {
      // Add new task
      offlineTasks.add(taskJson);
    }

    await prefs.setStringList(_offlineTasksKey, offlineTasks);
    debugPrint('Task saved offline: ${task.id}');
  }

  /// Gets all tasks from offline storage.
  static Future<List<Task>> getOfflineTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final offlineTasks = prefs.getStringList(_offlineTasksKey) ?? [];

    return offlineTasks.map((taskJson) {
      final decoded = jsonDecode(taskJson);
      return Task.fromJson(decoded);
    }).toList();
  }

  /// Deletes a task from offline storage.
  static Future<void> deleteTaskOffline(String taskId) async {
    final prefs = await SharedPreferences.getInstance();
    final offlineTasks = prefs.getStringList(_offlineTasksKey) ?? [];

    final filteredTasks = offlineTasks.where((taskJson) {
      final decoded = jsonDecode(taskJson);
      return decoded['id'] != taskId;
    }).toList();

    await prefs.setStringList(_offlineTasksKey, filteredTasks);
    debugPrint('Task deleted offline: $taskId');
  }

  /// Saves user data to offline storage.
  static Future<void> saveUserOffline(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_offlineUserKey, jsonEncode(userData));
    debugPrint('User data saved offline');
  }

  /// Gets user data from offline storage.
  static Future<Map<String, dynamic>?> getOfflineUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_offlineUserKey);

    if (userJson == null) return null;

    return jsonDecode(userJson);
  }

  /// Checks if the app should switch to offline mode.
  static Future<bool> shouldSwitchToOfflineMode() async {
    // Check Supabase status
    final status = await SupabaseChecker.checkSupabaseStatus();

    // If we can't connect to Supabase but have internet, suggest offline mode
    if (!status['isActive'] && status['internetConnected'] == true) {
      return true;
    }

    // If we have no internet at all, definitely use offline mode
    if (status['internetConnected'] == false) {
      return true;
    }

    return false;
  }

  /// Shows an offline mode dialog to the user.
  static Future<bool> showOfflineModeDialog(BuildContext context) async {
    final status = await SupabaseChecker.checkSupabaseStatus();
    final suggestions = (status['suggestions'] as List<dynamic>?)?.cast<String>() ?? [];

    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Connection Issue'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Unable to connect to the server. Would you like to continue in offline mode?',
            ),
            const SizedBox(height: 16),
            if (suggestions.isNotEmpty) ...[
              const Text(
                'Possible issues:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...suggestions.map((suggestion) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• '),
                    Expanded(child: Text(suggestion)),
                  ],
                ),
              )),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Try Again'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Use Offline Mode'),
          ),
        ],
      ),
    ) ?? false;
  }
}

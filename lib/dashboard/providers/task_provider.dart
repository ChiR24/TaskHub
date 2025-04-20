import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:mini_taskhub/dashboard/models/task_model.dart';
import 'package:mini_taskhub/dashboard/services/task_service.dart';

class TaskProvider with ChangeNotifier {
  final TaskService _taskService = TaskService();

  // Tasks
  List<Task> _tasks = [];
  List<Task> get tasks => _tasks;

  // Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Error message
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Initialize tasks for a user
  Future<void> initTasks(String userId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      // Don't notify listeners here to avoid build-time issues

      // Get tasks for the user
      await _taskService.getTasks(userId);

      // Add mock tasks if needed
      await _taskService.addMockTasks(userId);

      _isLoading = false;
      // Notify listeners after all tasks are loaded
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Set up task listener
  StreamSubscription? _taskSubscription;

  void setupTaskListener(String userId) {
    // Cancel any existing subscription
    _taskSubscription?.cancel();

    // Set up new subscription
    _taskSubscription = _taskService.taskStateChanges.listen((tasks) {
      _tasks = tasks;
      notifyListeners();
    });
  }

  // Dispose task listener
  void disposeTaskListener() {
    _taskSubscription?.cancel();
    _taskSubscription = null;
  }

  // Add a task
  Future<void> addTask(Task task) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _taskService.addTask(task);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Update a task
  Future<void> updateTask(Task task) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _taskService.updateTask(task);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Delete a task
  Future<void> deleteTask(String taskId, String userId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _taskService.deleteTask(taskId, userId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Toggle task status
  Future<void> toggleTaskStatus(String taskId, String userId) async {
    try {
      await _taskService.toggleTaskStatus(taskId, userId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Clear error message
  void clearErrorMessage() {
    _errorMessage = null;
    notifyListeners();
  }
}

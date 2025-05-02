import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:mini_taskhub/dashboard/models/filter_model.dart';
import 'package:mini_taskhub/dashboard/models/task_model.dart';
import 'package:mini_taskhub/dashboard/services/task_service.dart';

/// Provider that manages task state and operations.
///
/// This class serves as the interface between the UI and the task service.
/// It handles task filtering, loading states, and error messages.
class TaskProvider with ChangeNotifier {
  /// Service for interacting with the task database
  final TaskService _taskService = TaskService();

  /// All tasks for the current user
  List<Task> _tasks = [];

  /// Getter for all tasks
  List<Task> get tasks => _tasks;

  /// Tasks filtered according to the current filter settings
  List<Task> _filteredTasks = [];

  /// Getter for filtered tasks (used by the UI)
  List<Task> get filteredTasks => _filteredTasks;

  /// Current filter settings
  TaskFilter _filter = const TaskFilter();

  /// Getter for the current filter
  TaskFilter get filter => _filter;

  /// Whether a task operation is in progress
  bool _isLoading = false;

  /// Getter for loading state (used to show loading indicators)
  bool get isLoading => _isLoading;

  /// Error message from the most recent operation
  String? _errorMessage;

  /// Getter for error message (used to display errors to the user)
  String? get errorMessage => _errorMessage;

  /// Initializes tasks for a user.
  ///
  /// This method fetches all tasks for the specified user, adds mock tasks if needed,
  /// and applies the current filter. It should be called when the user logs in or
  /// when the app starts.
  ///
  /// [userId] The ID of the user whose tasks to initialize.
  Future<void> initTasks(String userId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      // Don't notify listeners here to avoid build-time issues

      // Get tasks for the user
      await _taskService.getTasks(userId);

      // Add mock tasks if needed
      await _taskService.addMockTasks(userId);

      // Initialize filtered tasks
      _applyFilter();

      _isLoading = false;
      // Notify listeners after all tasks are loaded
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Stream subscription for real-time task updates
  StreamSubscription? _taskSubscription;

  /// Sets up a listener for real-time task updates.
  ///
  /// This method subscribes to the task service's stream of task changes,
  /// updating the task list and notifying listeners whenever tasks change.
  /// It should be called when the user logs in or when the app starts.
  ///
  /// [userId] The ID of the user whose tasks to listen for.
  void setupTaskListener(String userId) {
    // Cancel any existing subscription
    _taskSubscription?.cancel();

    // Set up new subscription
    _taskSubscription = _taskService.taskStateChanges.listen((tasks) {
      _tasks = tasks;
      _applyFilter();
      notifyListeners();
    });
  }

  /// Applies the current filter to the task list.
  ///
  /// This private method updates the filtered task list based on the current filter settings.
  void _applyFilter() {
    _filteredTasks = _filter.apply(_tasks);
  }

  /// Sets a new filter and applies it to the task list.
  ///
  /// This method updates the filter settings and refreshes the filtered task list.
  /// It should be called when the user changes the filter settings.
  ///
  /// [filter] The new filter to apply.
  void setFilter(TaskFilter filter) {
    _filter = filter;
    _applyFilter();
    notifyListeners();
  }

  /// Disposes of the task listener.
  ///
  /// This method cancels the subscription to the task service's stream of task changes.
  /// It should be called when the user logs out or when the app is closed.
  void disposeTaskListener() {
    _taskSubscription?.cancel();
    _taskSubscription = null;
  }

  /// Adds a new task.
  ///
  /// This method creates a new task in the database and updates the UI accordingly.
  /// It sets the loading state and error message as appropriate.
  ///
  /// [task] The task to add.
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

  /// Updates an existing task.
  ///
  /// This method updates a task in the database and refreshes the UI.
  /// It sets the loading state and error message as appropriate.
  ///
  /// [task] The task with updated values.
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

  /// Deletes a task.
  ///
  /// This method removes a task from the database and updates the UI.
  /// It sets the loading state and error message as appropriate.
  ///
  /// [taskId] The ID of the task to delete.
  /// [userId] The ID of the user who owns the task.
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

  /// Toggles the completion status of a task.
  ///
  /// This method is a lightweight way to mark a task as completed or pending.
  /// Unlike other methods, it doesn't set the loading state, but it does handle errors.
  ///
  /// [taskId] The ID of the task to toggle.
  /// [userId] The ID of the user who owns the task.
  Future<void> toggleTaskStatus(String taskId, String userId) async {
    try {
      await _taskService.toggleTaskStatus(taskId, userId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Clears the current error message.
  ///
  /// This method should be called after displaying an error to the user,
  /// or when starting a new operation that should not show the previous error.
  void clearErrorMessage() {
    _errorMessage = null;
    notifyListeners();
  }
}

import 'dart:async';
import 'package:mini_taskhub/app/supabase_config.dart';
import 'package:mini_taskhub/dashboard/models/task_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TaskService {
  // Singleton pattern
  static final TaskService _instance = TaskService._internal();
  factory TaskService() => _instance;
  TaskService._internal();

  // Supabase client
  final _supabase = SupabaseConfig.client;

  // Task state controller
  final _taskStateController = StreamController<List<Task>>.broadcast();
  Stream<List<Task>> get taskStateChanges => _taskStateController.stream;

  // Table name
  static const String _tableName = 'tasks';

  // Get all tasks for a user
  Future<List<Task>> getTasks(String userId) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final tasks = response.map((task) => Task.fromSupabase(task)).toList();

      // Notify listeners
      _taskStateController.add(tasks as List<Task>);

      return tasks as List<Task>;
    } catch (e) {
      throw Exception('Failed to get tasks: ${e.toString()}');
    }
  }

  // Add a task
  Future<Task> addTask(Task task) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .insert(task.toMap())
          .select()
          .single();

      final newTask = Task.fromSupabase(response);

      // Refresh tasks
      await getTasks(task.userId);

      return newTask;
    } catch (e) {
      throw Exception('Failed to add task: ${e.toString()}');
    }
  }

  // Update a task
  Future<Task> updateTask(Task task) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .update(task.toMap())
          .eq('id', task.id)
          .select()
          .single();

      final updatedTask = Task.fromSupabase(response);

      // Refresh tasks
      await getTasks(task.userId);

      return updatedTask;
    } catch (e) {
      throw Exception('Failed to update task: ${e.toString()}');
    }
  }

  // Delete a task
  Future<void> deleteTask(String taskId, String userId) async {
    try {
      await _supabase
          .from(_tableName)
          .delete()
          .eq('id', taskId);

      // Refresh tasks
      await getTasks(userId);
    } catch (e) {
      throw Exception('Failed to delete task: ${e.toString()}');
    }
  }

  // Toggle task status
  Future<Task> toggleTaskStatus(String taskId, String userId) async {
    try {
      // Get current task
      final currentTask = await _supabase
          .from(_tableName)
          .select()
          .eq('id', taskId)
          .single();

      // Toggle status
      final isCompleted = currentTask['is_completed'] == true;

      // Update task
      final response = await _supabase
          .from(_tableName)
          .update({'is_completed': !isCompleted})
          .eq('id', taskId)
          .select()
          .single();

      final updatedTask = Task.fromSupabase(response);

      // Refresh tasks
      await getTasks(userId);

      return updatedTask;
    } catch (e) {
      throw Exception('Failed to toggle task status: ${e.toString()}');
    }
  }

  // Add mock tasks for testing
  Future<void> addMockTasks(String userId) async {
    try {
      // Check if user already has tasks
      final existingTasks = await _supabase
          .from(_tableName)
          .select('id')
          .eq('user_id', userId);

      if (existingTasks.isNotEmpty) {
        // User already has tasks, no need to add mock tasks
        return;
      }

      // Add mock tasks
      final mockTasks = [
        Task(
          userId: userId,
          title: 'Complete Flutter project',
          description: 'Finish the Mini TaskHub app',
          status: TaskStatus.pending,
        ),
        Task(
          userId: userId,
          title: 'Learn Supabase',
          description: 'Study Supabase authentication and database',
          status: TaskStatus.pending,
        ),
        Task(
          userId: userId,
          title: 'Buy groceries',
          description: 'Milk, eggs, bread, and fruits',
          status: TaskStatus.completed,
        ),
        Task(
          userId: userId,
          title: 'Go for a run',
          description: '5km morning run',
          status: TaskStatus.pending,
        ),
        Task(
          userId: userId,
          title: 'Read a book',
          description: 'Flutter development book',
          status: TaskStatus.completed,
        ),
      ];

      for (final task in mockTasks) {
        await addTask(task);
      }
    } catch (e) {
      throw Exception('Failed to add mock tasks: ${e.toString()}');
    }
  }

  // Dispose
  void dispose() {
    _taskStateController.close();
  }
}

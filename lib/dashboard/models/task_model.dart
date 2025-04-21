import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Defines the possible statuses for a task.
///
/// Tasks can be either pending (not yet completed) or completed.
enum TaskStatus {
  /// Represents a task that is not yet completed.
  pending,

  /// Represents a task that has been completed.
  completed,
}

/// Defines the priority levels for a task.
///
/// Tasks can have low, medium, or high priority to indicate their importance.
enum TaskPriority {
  /// Low priority tasks.
  low,

  /// Medium priority tasks.
  medium,

  /// High priority tasks.
  high,
}

/// Defines the possible categories for a task.
///
/// Tasks can be categorized to help users organize and filter them.
class TaskCategory {
  /// Work-related tasks.
  static const String work = 'Work';

  /// Personal tasks.
  static const String personal = 'Personal';

  /// Shopping-related tasks.
  static const String shopping = 'Shopping';

  /// Health-related tasks.
  static const String health = 'Health';

  /// Education-related tasks.
  static const String education = 'Education';

  /// Finance-related tasks.
  static const String finance = 'Finance';

  /// Tasks that don't fit into other categories.
  static const String other = 'Other';

  /// A list of all possible task categories.
  static const List<String> all = [
    work,
    personal,
    shopping,
    health,
    education,
    finance,
    other,
  ];
}

/// Represents a task in the application.
///
/// A task is an activity that a user wants to track and complete.
/// Each task has properties like title, description, status, category, priority, and due date.
class Task {
  /// Unique identifier for the task.
  final String id;

  /// ID of the user who owns this task.
  final String userId;

  /// Title of the task.
  final String title;

  /// Optional detailed description of the task.
  final String? description;

  /// Current status of the task (pending or completed).
  final TaskStatus status;

  /// Category the task belongs to.
  final String category;

  /// Priority level of the task.
  final TaskPriority priority;

  /// Optional due date for the task.
  final DateTime? dueDate;

  /// When the task was created.
  final DateTime createdAt;

  /// When the task was last updated.
  final DateTime updatedAt;

  /// Creates a new task.
  ///
  /// If [id] is not provided, a new UUID will be generated.
  /// If [createdAt] or [updatedAt] are not provided, the current time will be used.
  Task({
    String? id,
    required this.userId,
    required this.title,
    this.description,
    this.status = TaskStatus.pending,
    this.category = TaskCategory.other,
    this.priority = TaskPriority.medium,
    this.dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Creates a copy of this task with the given fields replaced with new values.
  ///
  /// This is useful for updating a task without modifying the original.
  /// The [updatedAt] field is automatically set to the current time if not specified.
  Task copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    TaskStatus? status,
    String? category,
    TaskPriority? priority,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Converts this task to a map that can be stored in the database.
  ///
  /// This is used when saving the task to Supabase.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'is_completed': status == TaskStatus.completed,
      'category': category,
      'priority': priority.index,
      'due_date': dueDate?.toIso8601String(),
    };
  }

  /// Creates a task from a map of values, typically from the database.
  ///
  /// This handles parsing the database fields into the appropriate types.
  /// It includes robust error handling to deal with missing or invalid data.
  factory Task.fromMap(Map<String, dynamic> map) {
    try {
      return Task(
        id: map['id'] != null ? map['id'].toString() : const Uuid().v4(),
        userId: map['user_id'],
        title: map['title'],
        description: map['description'],
        status: map['is_completed'] == true ? TaskStatus.completed : TaskStatus.pending,
        category: map['category'] ?? TaskCategory.other,
        priority: map['priority'] != null ?
          TaskPriority.values[map['priority'] < TaskPriority.values.length ? map['priority'] : TaskPriority.medium.index] :
          TaskPriority.medium,
        dueDate: map['due_date'] != null ? DateTime.parse(map['due_date']) : null,
        createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : DateTime.now(),
        updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) :
                  map['created_at'] != null ? DateTime.parse(map['created_at']) : DateTime.now(),
      );
    } catch (e) {
      // Log error in production environment using a proper logging system
      rethrow;
    }
  }

  /// Creates a task from a Supabase response.
  ///
  /// This is a convenience method that delegates to [fromMap].
  factory Task.fromSupabase(Map<String, dynamic> map) {
    return Task.fromMap(map);
  }
}

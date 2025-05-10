import 'package:uuid/uuid.dart';

/// A model class representing a task.
class Task {
  final String id;
  final String title;
  final String? description;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? dueDate;
  final String? userId;
  final int? priority; // 1 = Low, 2 = Medium, 3 = High
  final String? category;
  
  Task({
    String? id,
    required this.title,
    this.description,
    this.isCompleted = false,
    DateTime? createdAt,
    this.dueDate,
    this.userId,
    this.priority,
    this.category,
  }) : 
    id = id ?? const Uuid().v4(),
    createdAt = createdAt ?? DateTime.now();
  
  /// Creates a copy of this task with the given fields replaced with the new values.
  Task copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? dueDate,
    String? userId,
    int? priority,
    String? category,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      userId: userId ?? this.userId,
      priority: priority ?? this.priority,
      category: category ?? this.category,
    );
  }
  
  /// Converts this task to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'is_completed': isCompleted,
      'created_at': createdAt.toIso8601String(),
      'due_date': dueDate?.toIso8601String(),
      'user_id': userId,
      'priority': priority,
      'category': category,
    };
  }
  
  /// Creates a task from a JSON map.
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      isCompleted: json['is_completed'] ?? false,
      createdAt: json['created_at'] != null 
        ? DateTime.parse(json['created_at']) 
        : DateTime.now(),
      dueDate: json['due_date'] != null 
        ? DateTime.parse(json['due_date']) 
        : null,
      userId: json['user_id'],
      priority: json['priority'],
      category: json['category'],
    );
  }
  
  /// Creates a task from a Supabase row.
  factory Task.fromSupabase(Map<String, dynamic> row) {
    return Task(
      id: row['id'],
      title: row['title'],
      description: row['description'],
      isCompleted: row['is_completed'] ?? false,
      createdAt: row['created_at'] != null 
        ? DateTime.parse(row['created_at']) 
        : DateTime.now(),
      dueDate: row['due_date'] != null 
        ? DateTime.parse(row['due_date']) 
        : null,
      userId: row['user_id'],
      priority: row['priority'],
      category: row['category'],
    );
  }
  
  @override
  String toString() {
    return 'Task{id: $id, title: $title, isCompleted: $isCompleted}';
  }
}

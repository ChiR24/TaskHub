import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum TaskStatus {
  pending,
  completed,
}

class Task {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final TaskStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Task({
    String? id,
    required this.userId,
    required this.title,
    this.description,
    this.status = TaskStatus.pending,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Task copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    TaskStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'title': title,
      'description': description,
      'is_completed': status == TaskStatus.completed,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'].toString(),
      userId: map['user_id'],
      title: map['title'],
      description: map['description'],
      status: map['is_completed'] == true ? TaskStatus.completed : TaskStatus.pending,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at'] ?? map['created_at']),
    );
  }

  factory Task.fromSupabase(Map<String, dynamic> map) {
    return Task.fromMap(map);
  }
}

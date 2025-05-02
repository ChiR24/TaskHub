import 'package:mini_taskhub/dashboard/models/task_model.dart';

/// Options for sorting tasks in the task list.
///
/// These options determine the order in which tasks are displayed to the user.
enum SortOption {
  /// Sort by creation date, newest first
  createdNewest,

  /// Sort by creation date, oldest first
  createdOldest,

  /// Sort by due date, earliest first
  dueDate,

  /// Sort by priority, highest first
  priority,

  /// Sort alphabetically by title
  alphabetical,
}

/// Filter for tasks in the task list.
///
/// This class defines criteria for filtering and sorting tasks.
/// It is immutable, so new instances must be created for different filter settings.
class TaskFilter {
  /// Categories to include in the filtered results.
  /// If null or empty, all categories are included.
  final List<String>? categories;

  /// Priorities to include in the filtered results.
  /// If null or empty, all priorities are included.
  final List<TaskPriority>? priorities;

  /// Whether to show completed tasks.
  /// If null, both completed and pending tasks are shown.
  final bool? showCompleted;

  /// How to sort the filtered tasks.
  final SortOption sortOption;

  /// Creates a new task filter with the specified criteria.
  ///
  /// By default, tasks are sorted by creation date (newest first).
  const TaskFilter({
    this.categories,
    this.priorities,
    this.showCompleted,
    this.sortOption = SortOption.createdNewest,
  });

  /// Creates a copy of this filter with the specified fields replaced with new values.
  ///
  /// This is useful for updating filter settings without modifying the original.
  /// Fields that are not specified will keep their original values.
  TaskFilter copyWith({
    List<String>? categories,
    List<TaskPriority>? priorities,
    bool? showCompleted,
    SortOption? sortOption,
  }) {
    return TaskFilter(
      categories: categories ?? this.categories,
      priorities: priorities ?? this.priorities,
      showCompleted: showCompleted ?? this.showCompleted,
      sortOption: sortOption ?? this.sortOption,
    );
  }

  /// Determines whether a task matches the filter criteria.
  ///
  /// This method checks if the task's category, priority, and completion status
  /// match the filter settings. It returns true if the task should be included
  /// in the filtered results, false otherwise.
  ///
  /// [task] The task to check against the filter criteria.
  /// Returns true if the task matches the filter, false otherwise.
  bool matches(Task task) {
    // Filter by category
    if (categories != null && categories!.isNotEmpty) {
      if (!categories!.contains(task.category)) {
        return false;
      }
    }

    // Filter by priority
    if (priorities != null && priorities!.isNotEmpty) {
      if (!priorities!.contains(task.priority)) {
        return false;
      }
    }

    // Filter by completion status
    if (showCompleted != null) {
      if (showCompleted! && task.status != TaskStatus.completed) {
        return false;
      } else if (!showCompleted! && task.status == TaskStatus.completed) {
        return false;
      }
    }

    return true;
  }

  /// Applies the filter to a list of tasks.
  ///
  /// This method filters the tasks according to the filter criteria and sorts
  /// them according to the sort option. It returns a new list containing only
  /// the tasks that match the filter, in the specified order.
  ///
  /// [tasks] The list of tasks to filter and sort.
  /// Returns a new list containing the filtered and sorted tasks.
  List<Task> apply(List<Task> tasks) {
    // Filter tasks
    final filteredTasks = tasks.where(matches).toList();

    // Sort tasks
    switch (sortOption) {
      case SortOption.createdNewest:
        filteredTasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SortOption.createdOldest:
        filteredTasks.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case SortOption.dueDate:
        filteredTasks.sort((a, b) {
          if (a.dueDate == null && b.dueDate == null) {
            return 0;
          } else if (a.dueDate == null) {
            return 1; // Tasks without due dates go last
          } else if (b.dueDate == null) {
            return -1; // Tasks with due dates go first
          }
          return a.dueDate!.compareTo(b.dueDate!); // Sort by due date (earliest first)
        });
        break;
      case SortOption.priority:
        filteredTasks.sort((a, b) => b.priority.index.compareTo(a.priority.index)); // Highest priority first
        break;
      case SortOption.alphabetical:
        filteredTasks.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase())); // A-Z
        break;
    }

    return filteredTasks;
  }
}

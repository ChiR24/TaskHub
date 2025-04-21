import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mini_taskhub/app/theme.dart';
import 'package:mini_taskhub/dashboard/models/task_model.dart';
import 'package:mini_taskhub/utils/constants.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

class TaskTile extends StatelessWidget {
  final Task task;
  final Function(String) onDelete;
  final Function(String) onToggleStatus;
  final Function(Task) onEdit;

  const TaskTile({
    super.key,
    required this.task,
    required this.onDelete,
    required this.onToggleStatus,
    required this.onEdit,
  });

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case TaskCategory.work:
        return Icons.work_outline;
      case TaskCategory.personal:
        return Icons.person_outline;
      case TaskCategory.shopping:
        return Icons.shopping_cart_outlined;
      case TaskCategory.health:
        return Icons.favorite_border;
      case TaskCategory.education:
        return Icons.school_outlined;
      case TaskCategory.finance:
        return Icons.account_balance_outlined;
      case TaskCategory.other:
      default:
        return Icons.category_outlined;
    }
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return AppTheme.primaryColor;
      case TaskPriority.high:
        return Colors.red;
      default:
        return AppTheme.primaryColor;
    }
  }

  String _getPriorityText(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
      default:
        return 'Medium';
    }
  }

  bool _isDueDateNear() {
    if (task.dueDate == null) return false;

    final now = DateTime.now();
    final difference = task.dueDate!.difference(now).inDays;

    // Return true if due date is today or in the past, or within 2 days
    return difference <= 2;
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final formattedDate = dateFormat.format(task.createdAt);
    final dueDateText = task.dueDate != null ? dateFormat.format(task.dueDate!) : null;

    // Generate a consistent pastel color based on the task title
    final int hashCode = task.title.hashCode;
    final double hue = (hashCode % 360).toDouble();
    final Color pastelColor = HSLColor.fromAHSL(0.2, hue, 0.7, 0.9).toColor();

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppConstants.smallPadding / 2,
      ),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => onEdit(task),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              icon: Icons.edit,
              label: 'Edit',
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppConstants.mediumBorderRadius),
                bottomLeft: Radius.circular(AppConstants.mediumBorderRadius),
              ),
            ),
            SlidableAction(
              onPressed: (_) => onDelete(task.id),
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Delete',
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(AppConstants.mediumBorderRadius),
                bottomRight: Radius.circular(AppConstants.mediumBorderRadius),
              ),
            ),
          ],
        ),
        child: Card(
          margin: EdgeInsets.zero,
          elevation: 2,
          color: AppTheme.cardColor,
          shadowColor: AppTheme.shadowColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: AppTheme.borderColor,
              width: 1,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: task.status == TaskStatus.completed
                    ? AppTheme.successColor.withOpacity(0.3)
                    : AppTheme.primaryColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.mediumPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row with checkbox and status badge
                  Row(
                    children: [
                      // Custom checkbox
                      GestureDetector(
                        onTap: () => onToggleStatus(task.id),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: task.status == TaskStatus.completed
                                ? AppTheme.primaryColor
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: task.status == TaskStatus.completed
                                  ? AppTheme.primaryColor
                                  : AppTheme.primaryColor.withOpacity(0.7),
                              width: 2,
                            ),
                          ),
                          child: task.status == TaskStatus.completed
                              ? const Icon(
                                  Icons.check,
                                  size: 16,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Task title
                      Expanded(
                        child: Text(
                          task.title,
                          style: TextStyle(
                            decoration: task.status == TaskStatus.completed
                                ? TextDecoration.lineThrough
                                : null,
                            color: task.status == TaskStatus.completed
                                ? AppTheme.textLightColor
                                : AppTheme.textColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Status badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: task.status == TaskStatus.completed
                              ? AppTheme.successColor.withOpacity(0.1)
                              : AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: task.status == TaskStatus.completed
                                ? AppTheme.successColor.withOpacity(0.5)
                                : AppTheme.primaryColor.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: task.status == TaskStatus.completed
                                    ? AppTheme.successColor
                                    : AppTheme.primaryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              task.status == TaskStatus.completed
                                  ? AppConstants.completedLabel
                                  : AppConstants.pendingLabel,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: task.status == TaskStatus.completed
                                    ? AppTheme.successColor
                                    : AppTheme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Description
                  if (task.description != null && task.description!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 12,
                        left: 36,
                      ),
                      child: Text(
                        task.description!,
                        style: TextStyle(
                          color: task.status == TaskStatus.completed
                              ? AppTheme.textLightColor.withOpacity(0.7)
                              : AppTheme.textLightColor,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                  // Category and priority
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 12,
                      left: 36,
                    ),
                    child: Row(
                      children: [
                        // Category
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.backgroundColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.borderColor,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getCategoryIcon(task.category),
                                size: 14,
                                color: AppTheme.primaryColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                task.category,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Priority
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getPriorityColor(task.priority).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _getPriorityColor(task.priority).withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.flag,
                                size: 14,
                                color: _getPriorityColor(task.priority),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _getPriorityText(task.priority),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _getPriorityColor(task.priority),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Dates and actions
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 12,
                      left: 36,
                    ),
                    child: Row(
                      children: [
                        // Created date
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 14,
                              color: AppTheme.textLightColor.withOpacity(0.7),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Created: $formattedDate',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textLightColor.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),

                        // Due date if available
                        if (dueDateText != null) ...[
                          const SizedBox(width: 12),
                          Row(
                            children: [
                              Icon(
                                Icons.event,
                                size: 14,
                                color: _isDueDateNear() ? Colors.red : AppTheme.textLightColor.withOpacity(0.7),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Due: $dueDateText',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _isDueDateNear() ? Colors.red : AppTheme.textLightColor.withOpacity(0.7),
                                  fontWeight: _isDueDateNear() ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ],

                        const Spacer(),
                        // Quick action buttons
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 20),
                          color: Colors.blue,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => onEdit(task),
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20),
                          color: AppTheme.errorColor,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => onDelete(task.id),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

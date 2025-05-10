import 'package:flutter/material.dart';
import 'package:mini_taskhub/app/theme.dart';
import 'package:mini_taskhub/dashboard/models/task_model.dart';
import 'package:mini_taskhub/utils/constants.dart';
import 'package:mini_taskhub/utils/validators.dart';
import 'package:mini_taskhub/widgets/custom_button.dart';
import 'package:mini_taskhub/widgets/custom_text_field.dart';

class AddTaskSheet extends StatefulWidget {
  final String userId;
  final Function(Task) onAddTask;
  final Task? taskToEdit;

  const AddTaskSheet({
    super.key,
    required this.userId,
    required this.onAddTask,
    this.taskToEdit,
  });

  @override
  State<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<AddTaskSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late TaskStatus _status;
  late String _category;
  late TaskPriority _priority;
  DateTime? _dueDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.taskToEdit?.title);
    _descriptionController = TextEditingController(text: widget.taskToEdit?.description);
    _status = widget.taskToEdit?.status ?? TaskStatus.pending;
    _category = widget.taskToEdit?.category ?? TaskCategory.other;
    _priority = widget.taskToEdit?.priority ?? TaskPriority.medium;
    _dueDate = widget.taskToEdit?.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

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

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final task = widget.taskToEdit != null
          ? widget.taskToEdit!.copyWith(
              title: _titleController.text.trim(),
              description: _descriptionController.text.trim(),
              status: _status,
              category: _category,
              priority: _priority,
              dueDate: _dueDate,
            )
          : Task(
              userId: widget.userId,
              title: _titleController.text.trim(),
              description: _descriptionController.text.trim(),
              status: _status,
              category: _category,
              priority: _priority,
              dueDate: _dueDate,
            );

      widget.onAddTask(task);

      setState(() {
        _isLoading = false;
      });

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.taskToEdit != null;

    return Container(
      padding: EdgeInsets.only(
        top: AppConstants.mediumPadding,
        left: AppConstants.mediumPadding,
        right: AppConstants.mediumPadding,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppConstants.mediumPadding,
      ),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowColor,
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppTheme.borderColor,
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
            ),
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isEditing ? Colors.blue : AppTheme.primaryColor,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        isEditing ? Icons.edit : Icons.add_task,
                        color: isEditing ? Colors.blue : AppTheme.primaryColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      isEditing ? 'Edit Task' : 'Add New Task',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: AppConstants.mediumPadding),

            // Title field
            CustomTextField(
              label: 'Task Title',
              hint: 'Enter task title',
              controller: _titleController,
              validator: Validators.validateTaskTitle,
              textInputAction: TextInputAction.next,
              autofocus: true,
            ),
            const SizedBox(height: AppConstants.mediumPadding),

            // Description field
            CustomTextField(
              label: 'Description (Optional)',
              hint: 'Enter task description',
              controller: _descriptionController,
              validator: Validators.validateTaskDescription,
              maxLines: 3,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: AppConstants.mediumPadding),

            // Category dropdown
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Category',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textColor,
                      ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _category,
                      isExpanded: true,
                      dropdownColor: AppTheme.cardColor,
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: AppTheme.primaryColor,
                      ),
                      items: TaskCategory.all.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Row(
                            children: [
                              Icon(
                                _getCategoryIcon(category),
                                color: AppTheme.primaryColor,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(category),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _category = newValue;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.mediumPadding),

            // Priority selection
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Priority',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textColor,
                      ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _priority = TaskPriority.low;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _priority == TaskPriority.low
                                ? Colors.green.withOpacity(0.1)
                                : AppTheme.backgroundColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _priority == TaskPriority.low
                                  ? Colors.green
                                  : AppTheme.borderColor,
                              width: _priority == TaskPriority.low ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.backgroundColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.green,
                                    width: 1,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.flag_outlined,
                                  color: Colors.green,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Low',
                                style: TextStyle(
                                  color: _priority == TaskPriority.low
                                      ? Colors.green
                                      : AppTheme.textLightColor,
                                  fontWeight: _priority == TaskPriority.low
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _priority = TaskPriority.medium;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _priority == TaskPriority.medium
                                ? AppTheme.primaryColor.withOpacity(0.1)
                                : AppTheme.backgroundColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _priority == TaskPriority.medium
                                  ? AppTheme.primaryColor
                                  : AppTheme.borderColor,
                              width: _priority == TaskPriority.medium ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.backgroundColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppTheme.primaryColor,
                                    width: 1,
                                  ),
                                ),
                                child: Icon(
                                  Icons.flag,
                                  color: AppTheme.primaryColor,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Medium',
                                style: TextStyle(
                                  color: _priority == TaskPriority.medium
                                      ? AppTheme.primaryColor
                                      : AppTheme.textLightColor,
                                  fontWeight: _priority == TaskPriority.medium
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _priority = TaskPriority.high;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _priority == TaskPriority.high
                                ? Colors.red.withOpacity(0.1)
                                : AppTheme.backgroundColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _priority == TaskPriority.high
                                  ? Colors.red
                                  : AppTheme.borderColor,
                              width: _priority == TaskPriority.high ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.backgroundColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.red,
                                    width: 1,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.flag,
                                  color: Colors.red,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'High',
                                style: TextStyle(
                                  color: _priority == TaskPriority.high
                                      ? Colors.red
                                      : AppTheme.textLightColor,
                                  fontWeight: _priority == TaskPriority.high
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppConstants.mediumPadding),

            // Due date picker
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Due Date (Optional)',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textColor,
                      ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _dueDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.dark(
                              primary: AppTheme.primaryColor,
                              onPrimary: Colors.black,
                              surface: AppTheme.cardColor,
                              onSurface: AppTheme.textColor,
                            ),
                            dialogBackgroundColor: AppTheme.cardColor,
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      setState(() {
                        _dueDate = picked;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.borderColor),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: AppTheme.primaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _dueDate != null
                                  ? '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'
                                  : 'Select a date',
                              style: TextStyle(
                                color: _dueDate != null
                                    ? AppTheme.textColor
                                    : AppTheme.textLightColor,
                              ),
                            ),
                          ],
                        ),
                        if (_dueDate != null)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            color: AppTheme.textLightColor,
                            iconSize: 20,
                            onPressed: () {
                              setState(() {
                                _dueDate = null;
                              });
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.mediumPadding),

            // Status field (only for editing)
            if (isEditing)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textColor,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _status = TaskStatus.pending;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _status == TaskStatus.pending
                                  ? AppTheme.primaryColor.withOpacity(0.1)
                                  : AppTheme.backgroundColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _status == TaskStatus.pending
                                    ? AppTheme.primaryColor
                                    : AppTheme.borderColor,
                                width: _status == TaskStatus.pending ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.backgroundColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppTheme.primaryColor,
                                      width: 1,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.pending_actions,
                                    color: AppTheme.primaryColor,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  AppConstants.pendingLabel,
                                  style: TextStyle(
                                    color: _status == TaskStatus.pending
                                        ? AppTheme.primaryColor
                                        : AppTheme.textLightColor,
                                    fontWeight: _status == TaskStatus.pending
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _status = TaskStatus.completed;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _status == TaskStatus.completed
                                  ? AppTheme.successColor.withOpacity(0.1)
                                  : AppTheme.backgroundColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _status == TaskStatus.completed
                                    ? AppTheme.successColor
                                    : AppTheme.borderColor,
                                width: _status == TaskStatus.completed ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.backgroundColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppTheme.successColor,
                                      width: 1,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.check_circle_outline,
                                    color: AppTheme.successColor,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  AppConstants.completedLabel,
                                  style: TextStyle(
                                    color: _status == TaskStatus.completed
                                        ? AppTheme.successColor
                                        : AppTheme.textLightColor,
                                    fontWeight: _status == TaskStatus.completed
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.mediumPadding),
                ],
              ),

            // Submit button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isEditing ? Colors.blue : AppTheme.primaryColor,
                  foregroundColor: isEditing ? Colors.white : Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: isEditing ? Colors.white : Colors.black,
                          strokeWidth: 2,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isEditing ? Icons.update : Icons.add_task,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isEditing ? 'Update Task' : 'Add Task',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: AppConstants.mediumPadding),
          ],
        ),
      ),
    );
  }
}

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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.taskToEdit?.title);
    _descriptionController = TextEditingController(text: widget.taskToEdit?.description);
    _status = widget.taskToEdit?.status ?? TaskStatus.pending;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
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
            )
          : Task(
              userId: widget.userId,
              title: _titleController.text.trim(),
              description: _descriptionController.text.trim(),
              status: _status,
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

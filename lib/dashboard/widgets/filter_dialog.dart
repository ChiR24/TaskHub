import 'package:flutter/material.dart';
import 'package:mini_taskhub/app/theme.dart';
import 'package:mini_taskhub/dashboard/models/filter_model.dart';
import 'package:mini_taskhub/dashboard/models/task_model.dart';
import 'package:mini_taskhub/utils/constants.dart';

class FilterDialog extends StatefulWidget {
  final TaskFilter currentFilter;
  final Function(TaskFilter) onApplyFilter;

  const FilterDialog({
    super.key,
    required this.currentFilter,
    required this.onApplyFilter,
  });

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  late List<String> _selectedCategories;
  late List<TaskPriority> _selectedPriorities;
  late bool? _showCompleted;
  late SortOption _sortOption;

  @override
  void initState() {
    super.initState();
    _selectedCategories = widget.currentFilter.categories ?? [];
    _selectedPriorities = widget.currentFilter.priorities ?? [];
    _showCompleted = widget.currentFilter.showCompleted;
    _sortOption = widget.currentFilter.sortOption;
  }

  void _toggleCategory(String category) {
    setState(() {
      if (_selectedCategories.contains(category)) {
        _selectedCategories.remove(category);
      } else {
        _selectedCategories.add(category);
      }
    });
  }

  void _togglePriority(TaskPriority priority) {
    setState(() {
      if (_selectedPriorities.contains(priority)) {
        _selectedPriorities.remove(priority);
      } else {
        _selectedPriorities.add(priority);
      }
    });
  }

  void _applyFilter() {
    final filter = TaskFilter(
      categories: _selectedCategories.isEmpty ? null : _selectedCategories,
      priorities: _selectedPriorities.isEmpty ? null : _selectedPriorities,
      showCompleted: _showCompleted,
      sortOption: _sortOption,
    );
    widget.onApplyFilter(filter);
    Navigator.pop(context);
  }

  void _resetFilter() {
    setState(() {
      _selectedCategories = [];
      _selectedPriorities = [];
      _showCompleted = null;
      _sortOption = SortOption.createdNewest;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.mediumPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                          color: AppTheme.primaryColor,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.filter_list,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Filter Tasks',
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
            const SizedBox(height: AppConstants.smallPadding),

            // Categories
            Text(
              'Categories',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: TaskCategory.all.map((category) {
                final isSelected = _selectedCategories.contains(category);
                return FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (_) => _toggleCategory(category),
                  backgroundColor: AppTheme.backgroundColor,
                  selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                  checkmarkColor: AppTheme.primaryColor,
                  labelStyle: TextStyle(
                    color: isSelected ? AppTheme.primaryColor : AppTheme.textColor,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
                    ),
                  ),
                  avatar: Icon(
                    _getCategoryIcon(category),
                    size: 16,
                    color: isSelected ? AppTheme.primaryColor : AppTheme.textLightColor,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppConstants.mediumPadding),

            // Priorities
            Text(
              'Priority',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: TaskPriority.values.map((priority) {
                final isSelected = _selectedPriorities.contains(priority);
                final color = _getPriorityColor(priority);
                return FilterChip(
                  label: Text(_getPriorityText(priority)),
                  selected: isSelected,
                  onSelected: (_) => _togglePriority(priority),
                  backgroundColor: AppTheme.backgroundColor,
                  selectedColor: color.withOpacity(0.2),
                  checkmarkColor: color,
                  labelStyle: TextStyle(
                    color: isSelected ? color : AppTheme.textColor,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isSelected ? color : AppTheme.borderColor,
                    ),
                  ),
                  avatar: Icon(
                    Icons.flag,
                    size: 16,
                    color: isSelected ? color : AppTheme.textLightColor,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppConstants.mediumPadding),

            // Status
            Text(
              'Status',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _showCompleted = false;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _showCompleted == false
                            ? AppTheme.primaryColor.withOpacity(0.1)
                            : AppTheme.backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _showCompleted == false
                              ? AppTheme.primaryColor
                              : AppTheme.borderColor,
                          width: _showCompleted == false ? 2 : 1,
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
                              size: 20,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Pending',
                            style: TextStyle(
                              color: _showCompleted == false
                                  ? AppTheme.primaryColor
                                  : AppTheme.textLightColor,
                              fontWeight: _showCompleted == false
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
                        _showCompleted = true;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _showCompleted == true
                            ? AppTheme.successColor.withOpacity(0.1)
                            : AppTheme.backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _showCompleted == true
                              ? AppTheme.successColor
                              : AppTheme.borderColor,
                          width: _showCompleted == true ? 2 : 1,
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
                              size: 20,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Completed',
                            style: TextStyle(
                              color: _showCompleted == true
                                  ? AppTheme.successColor
                                  : AppTheme.textLightColor,
                              fontWeight: _showCompleted == true
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
                        _showCompleted = null;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _showCompleted == null
                            ? Colors.blue.withOpacity(0.1)
                            : AppTheme.backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _showCompleted == null
                              ? Colors.blue
                              : AppTheme.borderColor,
                          width: _showCompleted == null ? 2 : 1,
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
                                color: Colors.blue,
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.all_inclusive,
                              color: Colors.blue,
                              size: 20,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'All',
                            style: TextStyle(
                              color: _showCompleted == null
                                  ? Colors.blue
                                  : AppTheme.textLightColor,
                              fontWeight: _showCompleted == null
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

            // Sort options
            Text(
              'Sort By',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<SortOption>(
                  value: _sortOption,
                  isExpanded: true,
                  dropdownColor: AppTheme.cardColor,
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: AppTheme.primaryColor,
                  ),
                  items: [
                    DropdownMenuItem(
                      value: SortOption.createdNewest,
                      child: _buildSortOptionItem(
                        Icons.access_time,
                        'Newest First',
                      ),
                    ),
                    DropdownMenuItem(
                      value: SortOption.createdOldest,
                      child: _buildSortOptionItem(
                        Icons.access_time,
                        'Oldest First',
                      ),
                    ),
                    DropdownMenuItem(
                      value: SortOption.dueDate,
                      child: _buildSortOptionItem(
                        Icons.event,
                        'Due Date',
                      ),
                    ),
                    DropdownMenuItem(
                      value: SortOption.priority,
                      child: _buildSortOptionItem(
                        Icons.flag,
                        'Priority',
                      ),
                    ),
                    DropdownMenuItem(
                      value: SortOption.alphabetical,
                      child: _buildSortOptionItem(
                        Icons.sort_by_alpha,
                        'Alphabetical',
                      ),
                    ),
                  ],
                  onChanged: (SortOption? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _sortOption = newValue;
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: AppConstants.mediumPadding),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _resetFilter,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textColor,
                      side: BorderSide(color: AppTheme.borderColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Reset'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _applyFilter,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Apply'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOptionItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppTheme.primaryColor,
        ),
        const SizedBox(width: 12),
        Text(text),
      ],
    );
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
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mini_taskhub/app/theme.dart';
import 'package:mini_taskhub/auth/providers/auth_provider.dart';
import 'package:mini_taskhub/dashboard/models/filter_model.dart';
import 'package:mini_taskhub/dashboard/models/task_model.dart';
import 'package:mini_taskhub/dashboard/providers/task_provider.dart';
import 'package:mini_taskhub/dashboard/widgets/add_task_sheet.dart';
import 'package:mini_taskhub/dashboard/widgets/filter_dialog.dart';
import 'package:mini_taskhub/dashboard/widgets/task_tile.dart';
import 'package:mini_taskhub/utils/constants.dart';
import 'package:mini_taskhub/widgets/loading_indicator.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  late TaskProvider _taskProvider;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Get the task provider
    _taskProvider = Provider.of<TaskProvider>(context, listen: false);
    // Use Future.microtask to delay initialization until after the build phase
    Future.microtask(() => _initTasks());
  }

  @override
  void dispose() {
    _tabController.dispose();
    // Dispose task listener using the stored reference
    _taskProvider.disposeTaskListener();
    super.dispose();
  }

  Future<void> _initTasks() async {
    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      // Set up the task listener first
      _taskProvider.setupTaskListener(authProvider.currentUser!.id);
      // Then initialize tasks
      await _taskProvider.initTasks(authProvider.currentUser!.id);
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _showAddTaskSheet() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.currentUser == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddTaskSheet(
        userId: authProvider.currentUser!.id,
        onAddTask: (task) {
          _taskProvider.addTask(task);
        },
      ),
    );
  }

  void _showEditTaskSheet(Task task) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.currentUser == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddTaskSheet(
        userId: authProvider.currentUser!.id,
        onAddTask: (updatedTask) {
          _taskProvider.updateTask(updatedTask);
        },
        taskToEdit: task,
      ),
    );
  }

  void _deleteTask(String taskId) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.currentUser == null) return;

    _taskProvider.deleteTask(taskId, authProvider.currentUser!.id);
  }

  void _toggleTaskStatus(String taskId) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.currentUser == null) return;

    _taskProvider.toggleTaskStatus(taskId, authProvider.currentUser!.id);
  }

  void _signOut() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppConstants.loginRoute);
    }
  }

  void _showFilterDialog() {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => FilterDialog(
        currentFilter: taskProvider.filter,
        onApplyFilter: (filter) {
          taskProvider.setFilter(filter);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);
    final user = authProvider.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Not authenticated'),
        ),
      );
    }

    // Apply filter to get filtered tasks
    final filteredTasks = taskProvider.filteredTasks;

    // Split filtered tasks into pending and completed
    final pendingTasks = filteredTasks
        .where((task) => task.status == TaskStatus.pending)
        .toList();

    final completedTasks = filteredTasks
        .where((task) => task.status == TaskStatus.completed)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryColor,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.access_time_filled,
                color: AppTheme.primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Day',
                    style: TextStyle(
                      color: AppTheme.textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  TextSpan(
                    text: 'Task',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: AppTheme.backgroundColor,
        foregroundColor: AppTheme.textColor,
        actions: [
          Row(
            children: [
              Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.filter_list),
                  color: AppTheme.primaryColor,
                  onPressed: _showFilterDialog,
                  tooltip: 'Filter Tasks',
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.person_outline),
                  color: AppTheme.primaryColor,
                  onPressed: () {
                    Navigator.pushNamed(context, AppConstants.profileRoute);
                  },
                  tooltip: 'Profile',
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.logout),
                  color: AppTheme.errorColor,
                  onPressed: _signOut,
                  tooltip: 'Logout',
                ),
              ),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(16),
              ),
              labelColor: Colors.black,
              unselectedLabelColor: AppTheme.textColor,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.pending_actions, size: 18),
                      const SizedBox(width: 8),
                      Text('Pending (${pendingTasks.length})'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle_outline, size: 18),
                      const SizedBox(width: 8),
                      Text('Completed (${completedTasks.length})'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: AppTheme.backgroundColor,
        ),
        child: _isLoading
            ? const LoadingIndicator()
            : RefreshIndicator(
                onRefresh: _initTasks,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Pending tasks tab
                    _buildTaskList(pendingTasks),

                    // Completed tasks tab
                    _buildTaskList(completedTasks),
                  ],
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskSheet,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.black,
        elevation: 4,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildTaskList(List<Task> tasks) {
    if (tasks.isEmpty) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.shadowColor,
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
            border: Border.all(
              color: AppTheme.borderColor,
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.primaryColor,
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.task_alt,
                  size: 60,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: AppConstants.mediumPadding),
              Text(
                'No tasks found',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.textColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: AppConstants.smallPadding),
              Text(
                'Tap the + button to add a new task',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textLightColor,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.largePadding),
              ElevatedButton.icon(
                onPressed: _showAddTaskSheet,
                icon: const Icon(Icons.add),
                label: const Text('Add Your First Task'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.mediumPadding),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskTile(
          task: task,
          onDelete: _deleteTask,
          onToggleStatus: _toggleTaskStatus,
          onEdit: _showEditTaskSheet,
        );
      },
    );
  }
}

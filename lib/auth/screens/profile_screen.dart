import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mini_taskhub/app/theme.dart';
import 'package:mini_taskhub/auth/providers/auth_provider.dart';
import 'package:mini_taskhub/utils/constants.dart';
import 'package:mini_taskhub/widgets/custom_button.dart';
import 'package:mini_taskhub/widgets/custom_text_field.dart';
import 'package:mini_taskhub/widgets/loading_indicator.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  bool _isEditing = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _loadProfile();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
    });

    // Use Future.microtask to avoid calling setState during build
    Future.microtask(() async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.getUserProfile();

      if (authProvider.profile != null && mounted) {
        setState(() {
          _fullNameController.text = authProvider.profile!.fullName ?? '';
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      setState(() {
        _isLoading = true;
      });

      final success = await authProvider.updateUserProfile(
        fullName: _fullNameController.text.trim(),
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          _isEditing = !success;
        });

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final profile = authProvider.profile;
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const LoadingIndicator()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.largePadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile avatar
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.primaryColor,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.shadowColor,
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        (profile?.fullName?.isNotEmpty == true
                                ? profile!.fullName![0]
                                : user?.email[0] ?? 'U')
                            .toUpperCase(),
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.largePadding),

                  // Email
                  Container(
                    padding: const EdgeInsets.all(AppConstants.mediumPadding),
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.shadowColor,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.backgroundColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.primaryColor,
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            Icons.email_outlined,
                            color: AppTheme.primaryColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Email',
                                style: TextStyle(
                                  color: AppTheme.textLightColor,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user?.email ?? 'Not available',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppConstants.mediumPadding),

                  // Profile form
                  Form(
                    key: _formKey,
                    child: Container(
                      padding: const EdgeInsets.all(AppConstants.mediumPadding),
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.shadowColor,
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Personal Information',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              IconButton(
                                icon: Icon(
                                  _isEditing ? Icons.close : Icons.edit,
                                  color: AppTheme.primaryColor,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isEditing = !_isEditing;
                                    if (!_isEditing) {
                                      // Reset to original values if canceling edit
                                      _fullNameController.text = profile?.fullName ?? '';
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: AppConstants.mediumPadding),

                          // Full name field
                          if (_isEditing)
                            CustomTextField(
                              label: 'Full Name',
                              hint: 'Enter your full name',
                              controller: _fullNameController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your name';
                                }
                                return null;
                              },
                              prefixIcon: Icons.person_outline,
                            )
                          else
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppTheme.backgroundColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppTheme.primaryColor,
                                      width: 1,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.person_outline,
                                    color: AppTheme.primaryColor,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Full Name',
                                        style: TextStyle(
                                          color: AppTheme.textLightColor,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        profile?.fullName?.isNotEmpty == true
                                            ? profile!.fullName!
                                            : 'Not set',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                          if (_isEditing) ...[
                            const SizedBox(height: AppConstants.largePadding),
                            SizedBox(
                              width: double.infinity,
                              child: CustomButton(
                                text: 'Save Changes',
                                onPressed: _updateProfile,
                                isLoading: authProvider.isLoading,
                                isFullWidth: true,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.largePadding),

                  // Account actions
                  Container(
                    padding: const EdgeInsets.all(AppConstants.mediumPadding),
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.shadowColor,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Account',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: AppConstants.mediumPadding),

                        // Logout button
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.errorColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.logout,
                              color: AppTheme.errorColor,
                              size: 24,
                            ),
                          ),
                          title: const Text('Logout'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: AppTheme.cardColor,
                                title: const Text('Logout'),
                                content: const Text('Are you sure you want to logout?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.errorColor,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Logout'),
                                  ),
                                ],
                              ),
                            );

                            if (confirmed == true && mounted) {
                              await authProvider.signOut();
                              if (mounted) {
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  AppConstants.loginRoute,
                                  (route) => false,
                                );
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class Validators {
  // Email validator
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    // Regular expression for email validation
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }

    return null;
  }

  // Password validator
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  // Task title validator
  static String? validateTaskTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Task title is required';
    }

    if (value.length < 3) {
      return 'Task title must be at least 3 characters';
    }

    if (value.length > 50) {
      return 'Task title must be less than 50 characters';
    }

    return null;
  }

  // Task description validator
  static String? validateTaskDescription(String? value) {
    if (value != null && value.length > 200) {
      return 'Task description must be less than 200 characters';
    }

    return null;
  }
}

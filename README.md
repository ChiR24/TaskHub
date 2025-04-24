# DayTask - Personal Task Tracker

A modern personal task tracking app built with Flutter and Supabase. This app allows users to manage their tasks with user authentication, a dashboard to view tasks, and the ability to add, edit, and delete tasks. The app features a clean, modern UI with subtle animations and a responsive design that works on both web and mobile platforms.

## Features

- **User Authentication**: Secure login and signup with Supabase Auth
- **Offline Mode**: Continue using the app even without internet connection
- **Custom Splash Screen**: Animated splash screen with app logo
- **Task Management**: Create, read, update, and delete tasks
- **Task Status Tracking**: Toggle between pending and completed states
- **Task Categories**: Organize tasks by categories (Work, Personal, Shopping, etc.)
- **Task Priorities**: Set priorities (Low, Medium, High) for better task management
- **Due Dates**: Set and track due dates for tasks
- **Task Filtering**: Filter tasks by status, category, and priority
- **Task Sorting**: Sort tasks by creation date, due date, priority, or alphabetically
- **Modern Dark UI**: Sleek dark theme with yellow accent colors
- **Responsive Design**: Works on various screen sizes (web, mobile, tablet)
- **Cross-Platform**: Runs on Web and Android platforms
- **Real-time Updates**: Changes to tasks are reflected in real-time
- **Data Persistence**: All data is stored in Supabase database
- **Clean Architecture**: Well-organized code structure following best practices
- **Row-Level Security**: Users can only access their own tasks
- **Subtle Animations**: Smooth transitions and animations for better UX
- **Comprehensive Documentation**: Well-documented code for easy maintenance

## Screenshots

See the `mockups` folder for UI design mockups of:

- Login Screen
- Signup Screen
- Dashboard Screen
- Add/Edit Task Screen

## Project Structure

```
lib/
│
├── main.dart                  # App entry point
├── app/
│   ├── app.dart               # App widget with providers
│   ├── theme.dart             # App theme configuration
│   └── supabase_config.dart   # Supabase configuration
├── auth/
│   ├── screens/
│   │   ├── login_screen.dart  # Login screen
│   │   ├── signup_screen.dart # Signup screen
│   │   └── profile_screen.dart # User profile screen
│   ├── models/
│   │   ├── user_model.dart    # User model
│   │   └── profile_model.dart # Profile model
│   ├── providers/
│   │   └── auth_provider.dart # Auth state management
│   └── services/
│       └── auth_service.dart  # Auth service with Supabase
├── dashboard/
│   ├── screens/
│   │   └── dashboard_screen.dart # Dashboard screen
│   ├── widgets/
│   │   ├── task_tile.dart     # Individual task item
│   │   ├── add_task_sheet.dart # Add task bottom sheet
│   │   └── filter_dialog.dart # Task filtering dialog
│   ├── models/
│   │   ├── task_model.dart    # Task model
│   │   └── filter_model.dart  # Task filter model
│   ├── providers/
│   │   └── task_provider.dart # Task state management
│   └── services/
│       └── task_service.dart  # Task CRUD operations with Supabase
├── utils/
│   ├── validators.dart        # Form validation helpers
│   └── constants.dart         # App constants
└── widgets/
    ├── custom_button.dart     # Reusable button widget
    ├── custom_text_field.dart # Reusable text field widget
    └── loading_indicator.dart # Loading indicator widget
```

## Setup Instructions

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK (latest stable version)
- A code editor (VS Code, Android Studio, etc.)

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/mini_taskhub.git
   ```

2. Navigate to the project directory:
   ```bash
   cd mini_taskhub
   ```

3. Install dependencies:
   ```bash
   flutter pub get
   ```

4. Set up the app icon and splash screen:
   - The app uses SVG files directly from the `assets/images` folder
   - No additional setup is required

5. Run the app on web:
   ```bash
   flutter run -d chrome
   ```

   Or run on Android:
   ```bash
   flutter run -d <android-device-id>
   ```

   If you encounter any issues, try cleaning and rebuilding:
   ```bash
   flutter clean
   flutter pub get
   flutter run -d android
   ```

### Supabase Setup

1. Create a Supabase account at [supabase.com](https://supabase.com)
2. Create a new project
3. Set up the database schema:
   ```sql
   -- Create profiles table
   CREATE TABLE IF NOT EXISTS profiles (
     id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
     email TEXT NOT NULL,
     full_name TEXT,
     avatar_url TEXT,
     created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
     updated_at TIMESTAMP WITH TIME ZONE
   );

   -- Create tasks table
   CREATE TABLE IF NOT EXISTS tasks (
     id UUID PRIMARY KEY,
     user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
     title TEXT NOT NULL,
     description TEXT,
     is_completed BOOLEAN DEFAULT FALSE,
     category TEXT DEFAULT 'Other',
     priority INTEGER DEFAULT 1,
     due_date TIMESTAMP WITH TIME ZONE,
     created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
     updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
   );

   -- Set up Row Level Security (RLS) for profiles
   ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

   -- Create policies for profiles
   CREATE POLICY "Enable read access for all users"
     ON profiles
     FOR SELECT
     USING (true);

   CREATE POLICY "Enable insert for authenticated users"
     ON profiles
     FOR INSERT
     WITH CHECK (auth.uid() = id);

   CREATE POLICY "Enable update for users based on id"
     ON profiles
     FOR UPDATE
     USING (auth.uid() = id);

   -- Set up Row Level Security (RLS) for tasks
   ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;

   -- Create policies for tasks
   CREATE POLICY "Users can view their own tasks"
     ON tasks
     FOR SELECT
     USING (auth.uid() = user_id);

   CREATE POLICY "Users can insert their own tasks"
     ON tasks
     FOR INSERT
     WITH CHECK (auth.uid() = user_id);

   CREATE POLICY "Users can update their own tasks"
     ON tasks
     FOR UPDATE
     USING (auth.uid() = user_id);

   CREATE POLICY "Users can delete their own tasks"
     ON tasks
     FOR DELETE
     USING (auth.uid() = user_id);

   -- Create a function to handle new user creation
   CREATE OR REPLACE FUNCTION public.handle_new_user()
   RETURNS TRIGGER AS $$
   BEGIN
     INSERT INTO public.profiles (id, email, created_at)
     VALUES (NEW.id, NEW.email, NOW());
     RETURN NEW;
   END;
   $$ LANGUAGE plpgsql SECURITY DEFINER;

   -- Create a trigger to call the function when a new user is created
   DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
   CREATE TRIGGER on_auth_user_created
     AFTER INSERT ON auth.users
     FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

   -- Create a function to update the updated_at timestamp
   CREATE OR REPLACE FUNCTION set_updated_at()
   RETURNS TRIGGER AS $$
   BEGIN
     NEW.updated_at = NOW();
     RETURN NEW;
   END;
   $$ LANGUAGE plpgsql;

   -- Create triggers to set updated_at on update
   CREATE TRIGGER set_profiles_updated_at
   BEFORE UPDATE ON profiles
   FOR EACH ROW
   EXECUTE FUNCTION set_updated_at();

   CREATE TRIGGER set_tasks_updated_at
   BEFORE UPDATE ON tasks
   FOR EACH ROW
   EXECUTE FUNCTION set_updated_at();
   ```

4. Get your Supabase URL and anon key from the project settings
5. Update the `supabase_config.dart` file with your credentials

## Hot Reload vs Hot Restart

- **Hot Reload**: Preserves the app state while updating the UI. It's useful when making UI changes without affecting the app state. To use hot reload, press `r` in the terminal or click the hot reload button in your IDE.

- **Hot Restart**: Resets the app state and rebuilds the app from scratch. It's useful when making changes to the app state or when hot reload doesn't work as expected. To use hot restart, press `R` in the terminal or click the hot restart button in your IDE.

## State Management

This project uses the Provider package for state management. The main providers are:

- `AuthProvider`: Manages authentication state
- `TaskProvider`: Manages task list and operations

## Dependencies

- `provider`: For state management
- `flutter_slidable`: For swipe-to-delete functionality
- `flutter_spinkit`: For loading indicators
- `google_fonts`: For custom fonts
- `intl`: For date formatting
- `uuid`: For generating unique IDs
- `supabase_flutter`: For Supabase integration
- `app_links`: For deep linking
- `path_provider`: For file system access
- `shared_preferences`: For local storage
- `url_launcher`: For opening URLs
- `flutter_datetime_picker_plus`: For date and time picking

## Future Improvements

- Add light mode theme option
- Add task reminders and notifications
- Implement offline support with local caching
- Add task sharing functionality
- Create recurring tasks
- Add data analytics and insights
- Add iOS support
- Implement task tags in addition to categories
- Add subtasks functionality
- Implement task attachments (files, images)
- Add collaborative task management for teams

## License

This project is licensed under the MIT License - see the LICENSE file for details.

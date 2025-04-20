# DayTask - Personal Task Tracker

A modern personal task tracking app built with Flutter and Supabase. This app allows users to manage their tasks with user authentication, a dashboard to view tasks, and the ability to add, edit, and delete tasks. The app features a clean, modern UI with subtle animations and a responsive design.

## Features

- **User Authentication**: Secure login and signup with Supabase Auth
- **Task Management**: Create, read, update, and delete tasks
- **Task Status Tracking**: Toggle between pending and completed states
- **Modern Dark UI**: Sleek dark theme with yellow accent colors
- **Responsive Design**: Works on various screen sizes
- **Real-time Updates**: Changes to tasks are reflected in real-time
- **Data Persistence**: All data is stored in Supabase database
- **Clean Architecture**: Well-organized code structure following best practices
- **Row-Level Security**: Users can only access their own tasks
- **Subtle Animations**: Smooth transitions and animations for better UX

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
│   │   └── signup_screen.dart # Signup screen
│   ├── models/
│   │   └── user_model.dart    # User model
│   ├── providers/
│   │   └── auth_provider.dart # Auth state management
│   └── services/
│       └── auth_service.dart  # Auth service with Supabase
├── dashboard/
│   ├── screens/
│   │   └── dashboard_screen.dart # Dashboard screen
│   ├── widgets/
│   │   ├── task_tile.dart     # Individual task item
│   │   └── add_task_sheet.dart # Add task bottom sheet
│   ├── models/
│   │   └── task_model.dart    # Task model
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

4. Run the app:
   ```bash
   flutter run
   ```

### Supabase Setup

1. Create a Supabase account at [supabase.com](https://supabase.com)
2. Create a new project
3. Set up the database schema:
   ```sql
   CREATE TABLE public.tasks (
     id bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
     user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
     title TEXT NOT NULL,
     description TEXT,
     is_completed BOOLEAN DEFAULT FALSE,
     created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
     updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
   );

   -- Row Level Security Policies
   ALTER TABLE public.tasks ENABLE ROW LEVEL SECURITY;

   -- Policy to allow users to see only their own tasks
   CREATE POLICY "Users can view their own tasks" ON public.tasks
     FOR SELECT USING (auth.uid() = user_id);

   -- Policy to allow users to insert their own tasks
   CREATE POLICY "Users can insert their own tasks" ON public.tasks
     FOR INSERT WITH CHECK (auth.uid() = user_id);

   -- Policy to allow users to update their own tasks
   CREATE POLICY "Users can update their own tasks" ON public.tasks
     FOR UPDATE USING (auth.uid() = user_id);

   -- Policy to allow users to delete their own tasks
   CREATE POLICY "Users can delete their own tasks" ON public.tasks
     FOR DELETE USING (auth.uid() = user_id);

   -- Create a function to update the updated_at timestamp
   CREATE OR REPLACE FUNCTION update_updated_at_column()
   RETURNS TRIGGER AS $$
   BEGIN
       NEW.updated_at = now();
       RETURN NEW;
   END;
   $$ LANGUAGE plpgsql;

   -- Create a trigger to automatically update the updated_at column
   CREATE TRIGGER update_tasks_updated_at
   BEFORE UPDATE ON public.tasks
   FOR EACH ROW
   EXECUTE FUNCTION update_updated_at_column();
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

## Future Improvements

- Add task filtering and sorting
- Implement task categories and tags
- Add light mode theme option
- Add task reminders and notifications
- Implement offline support with local caching
- Add task sharing functionality
- Implement task priorities
- Add due dates and deadlines
- Create recurring tasks
- Add data analytics and insights

## License

This project is licensed under the MIT License - see the LICENSE file for details.

# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.plugin.editing.** { *; }

# Play Core
-keep class com.google.android.play.core.** { *; }

# Supabase
-keep class io.supabase.** { *; }
-keep class com.google.gson.** { *; }
-keep class okhttp3.** { *; }
-keep class okio.** { *; }
-keep class retrofit2.** { *; }
-keep class com.squareup.** { *; }

# Network-related classes
-keep class java.net.** { *; }
-keep class javax.net.** { *; }
-keep class android.net.** { *; }
-keep class org.apache.http.** { *; }
-keep class org.json.** { *; }

# Keep DNS-related classes
-keep class sun.net.** { *; }
-keep class sun.security.** { *; }
-keep class java.security.** { *; }
-keep class javax.security.** { *; }
-keep class java.util.concurrent.** { *; }

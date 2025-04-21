import 'dart:async';
import 'package:mini_taskhub/app/supabase_config.dart';
import 'package:mini_taskhub/auth/models/profile_model.dart';
import 'package:mini_taskhub/auth/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;

  // Supabase client
  final _supabase = SupabaseConfig.client;

  // Current user
  User? _currentUser;
  User? get currentUser => _currentUser;

  // Auth state controller
  final _authStateController = StreamController<User?>.broadcast();
  Stream<User?> get authStateChanges => _authStateController.stream;

  // Constructor
  AuthService._internal() {
    // Initialize auth state listener
    _supabase.auth.onAuthStateChange.listen((data) {
      final supabaseUser = data.session?.user;
      if (supabaseUser != null) {
        _currentUser = User(
          id: supabaseUser.id,
          email: supabaseUser.email ?? '',
          name: supabaseUser.email?.split('@').first ?? 'User',
        );
      } else {
        _currentUser = null;
      }
      _authStateController.add(_currentUser);
    });

    // Set initial user if already authenticated
    final supabaseUser = _supabase.auth.currentUser;
    if (supabaseUser != null) {
      _currentUser = User(
        id: supabaseUser.id,
        email: supabaseUser.email ?? '',
        name: supabaseUser.email?.split('@').first ?? 'User',
      );
      _authStateController.add(_currentUser);
    }
  }

  // Sign in with email and password
  Future<User> signInWithEmailAndPassword(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final supabaseUser = response.user;
      if (supabaseUser == null) {
        throw Exception('Failed to sign in');
      }

      _currentUser = User(
        id: supabaseUser.id,
        email: supabaseUser.email ?? '',
        name: supabaseUser.email?.split('@').first ?? 'User',
      );

      return _currentUser!;
    } catch (e) {
      if (e is supabase.AuthException) {
        throw Exception(e.message);
      }
      throw Exception('Failed to sign in: ${e.toString()}');
    }
  }

  // Sign up with email and password
  Future<User> signUpWithEmailAndPassword(String email, String password) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      final supabaseUser = response.user;
      if (supabaseUser == null) {
        throw Exception('Failed to sign up');
      }

      _currentUser = User(
        id: supabaseUser.id,
        email: supabaseUser.email ?? '',
        name: supabaseUser.email?.split('@').first ?? 'User',
      );

      return _currentUser!;
    } catch (e) {
      if (e is supabase.AuthException) {
        throw Exception(e.message);
      }
      throw Exception('Failed to sign up: ${e.toString()}');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      _currentUser = null;
      _authStateController.add(null);
    } catch (e) {
      throw Exception('Failed to sign out: ${e.toString()}');
    }
  }

  // Check if user is signed in
  bool isSignedIn() {
    return _currentUser != null;
  }

  // Dispose
  void dispose() {
    _authStateController.close();
  }

  // Get user profile
  Future<Profile?> getUserProfile(String userId) async {
    try {
      // Try to get existing profile
      try {
        final response = await _supabase
            .from('profiles')
            .select('*')
            .eq('id', userId)
            .maybeSingle();

        if (response != null) {
          return Profile.fromJson(response);
        }
      } catch (e) {
        // If profile doesn't exist, create one
        if (_currentUser != null) {
          final newProfile = Profile.fromUser(_currentUser!);

          // Create a map for the profile
          final profileMap = {
            'id': newProfile.id,
            'email': newProfile.email,
            'created_at': DateTime.now().toIso8601String(),
          };

          await _supabase.from('profiles').insert(profileMap);

          // Fetch the newly created profile
          final response = await _supabase
              .from('profiles')
              .select('*')
              .eq('id', userId)
              .maybeSingle();

          if (response != null) {
            return Profile.fromJson(response);
          } else {
            return newProfile;
          }
        }
      }

      throw Exception('Failed to get or create user profile');
    } catch (e) {
      throw Exception('Failed to get user profile: ${e.toString()}');
    }
  }

  // Update user profile
  Future<void> updateUserProfile(Profile profile) async {
    try {
      // Create a map for the profile update
      final profileMap = {
        'full_name': profile.fullName,
        'avatar_url': profile.avatarUrl,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabase
        .from('profiles')
        .update(profileMap)
        .eq('id', profile.id);
    } catch (e) {
      throw Exception('Failed to update user profile: ${e.toString()}');
    }
  }
}

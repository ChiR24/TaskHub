import 'package:flutter/foundation.dart';
import 'package:mini_taskhub/auth/models/profile_model.dart';
import 'package:mini_taskhub/auth/models/user_model.dart';
import 'package:mini_taskhub/auth/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  // Current user
  User? get currentUser => _authService.currentUser;

  // Auth state stream
  Stream<User?> get authStateChanges => _authService.authStateChanges;

  // Profile
  Profile? _profile;
  Profile? get profile => _profile;

  // Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Error message
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Sign in with email and password
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authService.signInWithEmailAndPassword(email, password);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Sign up with email and password
  Future<bool> signUpWithEmailAndPassword(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authService.signUpWithEmailAndPassword(email, password);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authService.signOut();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Clear error message
  void clearErrorMessage() {
    _errorMessage = null;
    notifyListeners();
  }

  // Set error message
  void setErrorMessage(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  // Get user profile
  Future<Profile?> getUserProfile() async {
    try {
      _isLoading = true;
      notifyListeners();

      if (currentUser == null) {
        _isLoading = false;
        notifyListeners();
        return null;
      }

      final profile = await _authService.getUserProfile(currentUser!.id);
      _profile = profile;

      _isLoading = false;
      notifyListeners();
      return profile;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Update user profile
  Future<bool> updateUserProfile({
    String? fullName,
    String? avatarUrl,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      if (currentUser == null || _profile == null) {
        _isLoading = false;
        _errorMessage = 'User not authenticated';
        notifyListeners();
        return false;
      }

      final updatedProfile = _profile!.copyWith(
        fullName: fullName,
        avatarUrl: avatarUrl,
        updatedAt: DateTime.now(),
      );

      await _authService.updateUserProfile(updatedProfile);
      _profile = updatedProfile;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}

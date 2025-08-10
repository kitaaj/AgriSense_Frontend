import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../utils/logger.dart';

enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  AuthState _state = AuthState.initial;
  User? _user;
  String? _errorMessage;
  bool _isLoading = false;

  // Getters
  AuthState get state => _state;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _state == AuthState.authenticated && _user != null;

  // Initialize authentication state
  Future<void> initialize() async {
    _setState(AuthState.loading);
    
    try {
      await _apiService.initialize();
      
      if (_apiService.isAuthenticated) {
        await _loadUserFromStorage();
        if (_user != null) {
          // Verify token is still valid by fetching current user
          try {
            final currentUser = await _apiService.getCurrentUser();
            _user = currentUser;
            await _saveUserToStorage(currentUser);
            _setState(AuthState.authenticated);
          } catch (e) {
            // Token is invalid, clear stored data
            await _clearUserData();
            _setState(AuthState.unauthenticated);
          }
        } else {
          _setState(AuthState.unauthenticated);
        }
      } else {
        _setState(AuthState.unauthenticated);
      }
    } catch (e) {
      AppLogger.error('Failed to initialize auth: $e');
      _setState(AuthState.unauthenticated);
    }
  }

  // Login
  Future<bool> login(String username, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final request = LoginRequest(username: username, password: password);
      final response = await _apiService.login(request);
      
      _user = response.user;
      await _saveUserToStorage(response.user);
      _setState(AuthState.authenticated);
      
      AppLogger.info('User logged in successfully: ${response.user.username}');
      return true;
    } catch (e) {
      _setError(e.toString());
      AppLogger.error('Login failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Register
  Future<bool> register({
    required String username,
    required String email,
    required String password,
    String? fullName,
    String? phoneNumber,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final request = RegisterRequest(
        username: username,
        email: email,
        password: password,
        fullName: fullName,
        phoneNumber: phoneNumber,
      );
      
      final response = await _apiService.register(request);
      
      _user = response.user;
      await _saveUserToStorage(response.user);
      _setState(AuthState.authenticated);
      
      AppLogger.info('User registered successfully: ${response.user.username}');
      return true;
    } catch (e) {
      _setError(e.toString());
      AppLogger.error('Registration failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Logout
  Future<void> logout() async {
    _setLoading(true);
    
    try {
      await _apiService.logout();
    } catch (e) {
      AppLogger.warning('Logout API call failed: $e');
    }
    
    await _clearUserData();
    _setState(AuthState.unauthenticated);
    _setLoading(false);
    
    AppLogger.info('User logged out');
  }

  // Update profile
  Future<bool> updateProfile({
    String? fullName,
    String? phoneNumber,
    String? email,
  }) async {
    if (!isAuthenticated) return false;

    _setLoading(true);
    _clearError();

    try {
      final request = UpdateProfileRequest(
        fullName: fullName,
        phoneNumber: phoneNumber,
        email: email,
      );
      
      final response = await _apiService.updateProfile(request);
      _user = response.user;
      await _saveUserToStorage(response.user);
      
      AppLogger.info('Profile updated successfully');
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      AppLogger.error('Profile update failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Change password
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    if (!isAuthenticated) return false;

    _setLoading(true);
    _clearError();

    try {
      final request = ChangePasswordRequest(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      
      await _apiService.changePassword(request);
      
      AppLogger.info('Password changed successfully');
      return true;
    } catch (e) {
      _setError(e.toString());
      AppLogger.error('Password change failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Refresh user data
  Future<void> refreshUser() async {
    if (!isAuthenticated) return;

    try {
      final currentUser = await _apiService.getCurrentUser();
      _user = currentUser;
      await _saveUserToStorage(currentUser);
      notifyListeners();
    } catch (e) {
      AppLogger.error('Failed to refresh user data: $e');
    }
  }

  // Private methods
  void _setState(AuthState newState) {
    _state = newState;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    _setState(AuthState.error);
  }

  void _clearError() {
    _errorMessage = null;
  }

  Future<void> _saveUserToStorage(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.userDataKey, user.toJson().toString());
    } catch (e) {
      AppLogger.error('Failed to save user to storage: $e');
    }
  }

  Future<void> _loadUserFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString(AppConstants.userDataKey);
      
      if (userDataString != null) {
        // Note: This is a simplified approach. In production, you might want to use
        // proper JSON serialization or a more robust storage solution.
        // For now, we'll rely on the API to provide fresh user data.
        AppLogger.debug('User data found in storage');
      }
    } catch (e) {
      AppLogger.error('Failed to load user from storage: $e');
    }
  }

  Future<void> _clearUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.userDataKey);
      _user = null;
    } catch (e) {
      AppLogger.error('Failed to clear user data: $e');
    }
  }

  // Validation methods
  static String? validateUsername(String? username) {
    if (username == null || username.isEmpty) {
      return 'Username is required';
    }
    if (username.length < AppConstants.minUsernameLength) {
      return 'Username must be at least ${AppConstants.minUsernameLength} characters';
    }
    if (username.length > AppConstants.maxUsernameLength) {
      return 'Username must be less than ${AppConstants.maxUsernameLength} characters';
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username)) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    return null;
  }

  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < AppConstants.minPasswordLength) {
      return 'Password must be at least ${AppConstants.minPasswordLength} characters';
    }
    if (password.length > AppConstants.maxPasswordLength) {
      return 'Password must be less than ${AppConstants.maxPasswordLength} characters';
    }
    return null;
  }

  static String? validatePhoneNumber(String? phoneNumber) {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      return null; // Phone number is optional
    }
    if (!RegExp(r'^\+?[\d\s\-\(\)]{10,}$').hasMatch(phoneNumber)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  static String? validateFullName(String? fullName) {
    if (fullName == null || fullName.isEmpty) {
      return null; // Full name is optional
    }
    if (fullName.length < 2) {
      return 'Full name must be at least 2 characters';
    }
    if (fullName.length > 100) {
      return 'Full name must be less than 100 characters';
    }
    return null;
  }
}


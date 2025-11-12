import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  String? _errorMessage;
  
  // Getters
  String? get userEmail => _authService.currentUserEmail;
  bool get isLoggedIn => _authService.isLoggedIn;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // Sign in method
  Future<void> signIn(String email, String password, BuildContext context) async {
    try {
      print('AuthProvider: Starting sign in process');
      _setLoading(true);
      _clearError();
      
      final success = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _authService.isLoggedIn = success;
      if (success) {
        print('AuthProvider: Sign in successful, user: ${_authService.currentUserEmail}');
      }
      print('AuthProvider: Sign in result: $success');
      print('AuthProvider: isLoggedIn after sign in: ${_authService.isLoggedIn}');
      
      notifyListeners();
      print('AuthProvider: notifyListeners called - router will handle navigation');
    } catch (e) {
      print('AuthProvider: Sign in error: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
      print('AuthProvider: Sign in process completed, isLoggedIn: $isLoggedIn');
    }
  }
  
  // Sign out method
  Future<void> signOut() async {
    try {
      print('AuthProvider: Starting sign out process');
      _setLoading(true);
      _clearError();
      
      await _authService.signOut();
      
      print('AuthProvider: Sign out completed, isLoggedIn: $isLoggedIn');
      notifyListeners();
      print('AuthProvider: notifyListeners called - router will handle navigation');
    } catch (e) {
      print('AuthProvider: Sign out error: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
      print('AuthProvider: Sign out process completed');
    }
  }
  
  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }
  
  void _clearError() {
    _errorMessage = null;
  }
}
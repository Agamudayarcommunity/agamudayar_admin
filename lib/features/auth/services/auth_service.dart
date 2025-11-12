import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AuthService with ChangeNotifier {
  // API endpoint api/v1/auth/hello
  static const String _baseUrl = 'https://agamudayar.co.in/agamudayarbe/api/v1/';

  // Current user state
  bool _isLoggedIn = false;
  String? _currentUserEmail;
  String? _authToken;
  Map<String, dynamic>? _currentUser;

  // Get current user email
  String? get currentUserEmail => _currentUserEmail;

  // Get current user data
  Map<String, dynamic>? get currentUser => _currentUser;

  // Get auth token
  String? get authToken => _authToken;

  // Check if user is logged in
  bool get isLoggedIn => _isLoggedIn;

  // Set isLoggedIn
  set isLoggedIn(bool value) {
    _isLoggedIn = value;
    notifyListeners();
  }

  // Set loading state
  bool _loading = false;

  bool get loading => _loading;

  set loading(bool value) {
    _loading = value;
    notifyListeners();
  }

  // Sign in with userid and password (kept for AuthProvider)
  Future<bool> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${_baseUrl}auth/adminLogin'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'userid': email.trim(), 'password': password}),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        _authToken = responseData['token'];
        _currentUser = responseData['user'];
        _currentUserEmail = responseData['user']?['email'] ?? email;
        _isLoggedIn = true;
        notifyListeners();
        return true;
      } else {
        final errorData = json.decode(response.body);
        throw errorData['message'] ?? 'Invalid credentials';
      }
    } catch (e) {
      if (e is String) {
        throw e;
      }
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // Example login method using the base URL (optional)
  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${_baseUrl}auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _authToken = data['token'] as String?;
        _currentUserEmail = email;
        _isLoggedIn = true;
        notifyListeners();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    _authToken = null;
    _currentUserEmail = null;
    _isLoggedIn = false;
    _currentUser = null;
    notifyListeners();
  }
}

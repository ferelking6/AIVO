import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  String? _userId;
  String? _userEmail;

  bool get isAuthenticated => _isAuthenticated;
  String? get userId => _userId;
  String? get userEmail => _userEmail;

  Future<void> login(String email, String password) async {
    try {
      // TODO: Implement actual login logic
      _isAuthenticated = true;
      _userEmail = email;
      _userId = 'user_123';
      notifyListeners();
    } catch (e) {
      _isAuthenticated = false;
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      // TODO: Implement actual logout logic
      _isAuthenticated = false;
      _userId = null;
      _userEmail = null;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> register(String email, String password) async {
    try {
      // TODO: Implement actual registration logic
      _isAuthenticated = true;
      _userEmail = email;
      _userId = 'user_123';
      notifyListeners();
    } catch (e) {
      _isAuthenticated = false;
      rethrow;
    }
  }
}

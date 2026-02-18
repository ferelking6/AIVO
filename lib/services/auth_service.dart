import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aivo/utils/app_logger.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  final supabase = Supabase.instance.client;

  /// Initialize Supabase - Call this in main() before runApp()
  static Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
    try {
      AppLogger.log('Initializing Supabase with URL: $url', tag: 'AuthService');
      await Supabase.initialize(
        url: url,
        anonKey: anonKey,
      );
      AppLogger.log('✓ Supabase initialized successfully', tag: 'AuthService');
    } catch (e) {
      AppLogger.error('✗ Failed to initialize Supabase: $e', tag: 'AuthService');
      rethrow;
    }
  }

  /// Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    try {
      AppLogger.log('Attempting sign up for: $email', tag: 'AuthService');
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );
      AppLogger.log('✓ Sign up successful for: $email', tag: 'AuthService');
      return response;
    } catch (e) {
      AppLogger.error('✗ Sign up failed for $email: $e', tag: 'AuthService');
      rethrow;
    }
  }

  /// Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      AppLogger.log('Attempting sign in for: $email', tag: 'AuthService');
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      AppLogger.log('✓ Sign in successful for: $email', tag: 'AuthService');
      return response;
    } catch (e) {
      AppLogger.error('✗ Sign in failed for $email: $e', tag: 'AuthService');
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      AppLogger.log('Signing out...', tag: 'AuthService');
      await supabase.auth.signOut();
      AppLogger.log('✓ Sign out successful', tag: 'AuthService');
    } catch (e) {
      AppLogger.error('✗ Sign out failed: $e', tag: 'AuthService');
      rethrow;
    }
  }

  /// Get current user
  User? getCurrentUser() {
    return supabase.auth.currentUser;
  }

  /// Check if user is authenticated
  bool isAuthenticated() {
    return supabase.auth.currentUser != null;
  }

  /// Get current user email
  String? getCurrentUserEmail() {
    return supabase.auth.currentUser?.email;
  }

  /// Listen to auth state changes
  Stream<AuthState> authStateChanges() {
    return supabase.auth.onAuthStateChange;
  }
}

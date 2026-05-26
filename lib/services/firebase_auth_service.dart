import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  /// Get current authenticated user
  static User? get currentUser => _firebaseAuth.currentUser;

  /// Check if user is authenticated
  static bool get isAuthenticated => _firebaseAuth.currentUser != null;

  /// Sign up with email and password
  static Future<String?> signUp({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      // Validate email
      if (!_isValidEmail(email)) {
        return 'Please enter a valid email address';
      }

      // Validate password
      if (password.isEmpty) {
        return 'Password cannot be empty';
      }

      if (password.length < 6) {
        return 'Password must be at least 6 characters';
      }

      // Check if passwords match
      if (password != confirmPassword) {
        return 'Passwords do not match';
      }

      // Create user with email and password
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      return null; // Success
    } on FirebaseAuthException catch (e) {
      return _handleFirebaseAuthException(e);
    } catch (e) {
      return 'An unexpected error occurred: ${e.toString()}';
    }
  }

  /// Login with email and password
  static Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      // Validate inputs
      if (email.isEmpty || password.isEmpty) {
        return 'Email and password are required';
      }

      if (!_isValidEmail(email)) {
        return 'Please enter a valid email address';
      }

      // Sign in with email and password
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      return null; // Success
    } on FirebaseAuthException catch (e) {
      return _handleFirebaseAuthException(e);
    } catch (e) {
      return 'An unexpected error occurred: ${e.toString()}';
    }
  }

  /// Logout current user
  static Future<String?> logout() async {
    try {
      await _firebaseAuth.signOut();
      return null; // Success
    } catch (e) {
      return 'Failed to logout: ${e.toString()}';
    }
  }

  /// Validate email format
  static bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Handle Firebase auth exceptions
  static String _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address';
      case 'wrong-password':
        return 'Incorrect password. Please try again';
      case 'invalid-email':
        return 'Invalid email format';
      case 'user-disabled':
        return 'This user account has been disabled';
      case 'email-already-in-use':
        return 'Email is already registered. Please login or use a different email';
      case 'operation-not-allowed':
        return 'Email and password accounts are not enabled';
      case 'weak-password':
        return 'Password is too weak. Use a stronger password';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection';
      case 'too-many-requests':
        return 'Too many login attempts. Please try again later';
      default:
        return 'Authentication error: ${e.message}';
    }
  }
}

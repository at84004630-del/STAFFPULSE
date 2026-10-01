import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'revenuecat_service.dart';

/// Provider for the AuthService instance
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService.instance;
});

/// Stream provider for user authentication state changes
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

/// Service wrapper around FirebaseAuth.
/// Handles email/password authentication, anonymous check-in authentication,
/// and synchronizes user identity with RevenueCat.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Current authenticated user
  User? get currentUser => _auth.currentUser;

  /// Current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  /// Authentication state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Whether a user is currently signed in
  bool get isSignedIn => _auth.currentUser != null;

  /// Whether current user is anonymous
  bool get isAnonymous => _auth.currentUser?.isAnonymous ?? false;

  /// Sign in anonymously (used for employee pulse check-ins)
  Future<AuthResult> signInAnonymously() async {
    try {
      final credential = await _auth.signInAnonymously();
      final user = credential.user;
      if (user != null) {
        await RevenueCatService.instance.identifyUser(user.uid);
      }
      return AuthResult.success(user);
    } on FirebaseAuthException catch (e) {
      debugPrint('AuthService: Anonymous sign in failed: ${e.code} - ${e.message}');
      return AuthResult.failure(_mapFirebaseError(e));
    } catch (e) {
      debugPrint('AuthService: Unexpected error: $e');
      return AuthResult.failure(e.toString());
    }
  }

  /// Sign in with email and password (for managers)
  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user != null) {
        await RevenueCatService.instance.identifyUser(user.uid);
      }
      return AuthResult.success(user);
    } on FirebaseAuthException catch (e) {
      debugPrint('AuthService: Email sign in failed: ${e.code} - ${e.message}');
      return AuthResult.failure(_mapFirebaseError(e));
    } catch (e) {
      debugPrint('AuthService: Unexpected error: $e');
      return AuthResult.failure(e.toString());
    }
  }

  /// Register new manager with email and password
  Future<AuthResult> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user != null) {
        if (displayName != null && displayName.isNotEmpty) {
          await user.updateDisplayName(displayName);
        }
        await RevenueCatService.instance.identifyUser(user.uid);
      }
      return AuthResult.success(user);
    } on FirebaseAuthException catch (e) {
      debugPrint('AuthService: Registration failed: ${e.code} - ${e.message}');
      return AuthResult.failure(_mapFirebaseError(e));
    } catch (e) {
      debugPrint('AuthService: Unexpected error: $e');
      return AuthResult.failure(e.toString());
    }
  }

  /// Send password reset email
  Future<AuthResult> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return const AuthResult.success(null);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_mapFirebaseError(e));
    } catch (e) {
      return AuthResult.failure(e.toString());
    }
  }

  /// Sign out current user and reset RevenueCat state
  Future<void> signOut() async {
    try {
      await RevenueCatService.instance.logOut();
      await _auth.signOut();
    } catch (e) {
      debugPrint('AuthService: Error signing out: $e');
      await _auth.signOut();
    }
  }

  /// Human-friendly error messages
  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'operation-not-allowed':
        return 'Email/password or anonymous sign-in is not enabled in Firebase Console.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }
}

/// Result object for authentication operations
class AuthResult {
  final bool isSuccess;
  final User? user;
  final String? errorMessage;

  const AuthResult.success(this.user)
      : isSuccess = true,
        errorMessage = null;

  const AuthResult.failure(this.errorMessage)
      : isSuccess = false,
        user = null;
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Current user
  User? get currentUser => _auth.currentUser;

  /// Current user ID (convenience)
  String? get currentUserId => _auth.currentUser?.uid;

  /// Auth state stream — emits on login/logout
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign in with email and password
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _mapAuthException(e);
    }
  }

  /// Sign in with Google
  Future<UserCredential> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw FirebaseAuthException(
          code: 'ERROR_ABORTED_BY_USER',
          message: 'Sign in aborted by user',
        );
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _mapAuthException(e);
    } catch (e) {
      throw FirebaseAuthException(
        code: 'ERROR',
        message: 'Failed to sign in with Google: $e',
      );
    }
  }

  /// Register with email and password
Future<UserCredential> registerWithEmail({
  required String name,
  required String email,
  required String password,
}) async {
  try {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    // Keep auth profile in sync right after sign up so profile UI has data.
    final user = credential.user;
    if (user != null) {
      await user.updateDisplayName(name.trim());
      await user.reload();
    }

    return credential;
  } on FirebaseAuthException catch (e) {
    throw _mapAuthException(e);
  }
}

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  /// Delete account
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.delete();
    }
  }

  /// Send password reset email
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _mapAuthException(e);
    }
  }

  /// Map Firebase exceptions to user-friendly messages
  String _mapAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'No internet connection.';
      case 'ERROR_ABORTED_BY_USER':
        return 'Sign in aborted by user.';
      default:
        return e.message ?? 'Authentication failed.';
    }
  }
}

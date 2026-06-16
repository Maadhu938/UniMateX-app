import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/local/hive_service.dart';

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

  /// Delete account and all associated data.
  ///
  /// Order matters: Firestore data must be removed while the user is still
  /// authenticated (security rules require it), then the auth account is
  /// deleted. If the session is too old, Firebase requires a recent login;
  /// we re-authenticate Google users automatically and ask email users to
  /// sign in again.
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) return;
    final uid = user.uid;
    final db = FirebaseFirestore.instance;

    try {
      // 1. Delete Firestore data (batched for efficiency).
      const collections = ['attendance', 'timetable', 'notes', 'assignments', 'stats'];
      for (final collection in collections) {
        final snap = await db.collection('users').doc(uid).collection(collection).get();
        var batch = db.batch();
        var count = 0;
        for (final doc in snap.docs) {
          batch.delete(doc.reference);
          count++;
          if (count % 400 == 0) {
            await batch.commit();
            batch = db.batch();
          }
        }
        await batch.commit();
      }
      await db.collection('users').doc(uid).delete();

      // 2. Delete the auth account, re-authenticating if required.
      try {
        await user.delete();
      } on FirebaseAuthException catch (e) {
        if (e.code == 'requires-recent-login') {
          final reauthed = await _reauthenticate(user);
          if (reauthed) {
            await user.delete();
          } else {
            throw FirebaseAuthException(
              code: 'requires-recent-login',
              message: 'For your security, please log out and sign in again, then delete your account.',
            );
          }
        } else {
          rethrow;
        }
      }

      // 3. Clear local cache and Google session.
      await HiveService.clearAll();
      await _googleSignIn.signOut();
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw FirebaseAuthException(
        code: 'ERROR',
        message: 'Failed to delete account: $e',
      );
    }
  }

  /// Re-authenticates the current user. Google users are re-authenticated
  /// silently; returns false for providers we can't refresh here (e.g. email).
  Future<bool> _reauthenticate(User user) async {
    try {
      final isGoogle = user.providerData.any((p) => p.providerId == 'google.com');
      if (!isGoogle) return false;

      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return false;
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await user.reauthenticateWithCredential(credential);
      return true;
    } catch (_) {
      return false;
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

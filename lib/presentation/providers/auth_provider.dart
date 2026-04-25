import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/auth_service.dart';

/// Singleton AuthService provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Stream of auth state changes — null when logged out, User when logged in
final authStateProvider = StreamProvider<User?>((ref) {
  try {
    final authService = ref.watch(authServiceProvider);
    return authService.authStateChanges;
  } catch (e) {
    return const Stream.empty();
  }
});

/// Current user ID — null when not authenticated
final currentUserIdProvider = Provider<String?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.whenData((user) => user?.uid).value;
});

/// Provider for the user's display name, with Firestore fallback
final userDisplayNameProvider = StreamProvider<String>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return Stream.value('Student');
  
  // If user has a display name in Firebase Auth, use it
  if (user.displayName != null && user.displayName!.isNotEmpty && user.displayName != 'Student') {
    return Stream.value(user.displayName!);
  }
  
  // Otherwise, fetch from Firestore
  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .snapshots()
      .map((doc) => doc.data()?['name'] ?? 'Student');
});

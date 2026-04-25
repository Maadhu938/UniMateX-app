import 'package:cloud_firestore/cloud_firestore.dart';

/// Base Firestore helper — thin wrapper for common operations
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirebaseFirestore get instance => _firestore;

  /// Get a collection reference under a user
  CollectionReference<Map<String, dynamic>> userCollection(
      String userId, String collection) {
    return _firestore.collection('users/$userId/$collection');
  }

  /// Get a document reference under a user
  DocumentReference<Map<String, dynamic>> userDoc(
      String userId, String collection, String docId) {
    return _firestore.doc('users/$userId/$collection/$docId');
  }

  /// Get user's root document
  DocumentReference<Map<String, dynamic>> userRoot(String userId) {
    return _firestore.doc('users/$userId');
  }

  /// Batch write helper
  WriteBatch batch() => _firestore.batch();
}

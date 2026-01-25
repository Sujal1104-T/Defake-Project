import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:defake_app/models/user_model.dart';
import 'package:defake_app/models/scan_record.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create or update user profile
  Future<void> createUserProfile(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toJson());
  }

  // Get user profile
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  // Stream user profile for real-time updates
  Stream<UserModel?> streamUserProfile(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromJson(doc.data()!);
      }
      return null;
    });
  }

  // Update user stats
  Future<void> updateUserStats(String uid, {
    int? totalScans,
    int? threatsDetected,
  }) async {
    final Map<String, dynamic> updates = {};
    if (totalScans != null) updates['totalScans'] = totalScans;
    if (threatsDetected != null) updates['threatsDetected'] = threatsDetected;
    
    await _firestore.collection('users').doc(uid).update(updates);
  }

  // Increment scan count
  Future<void> incrementScanCount(String uid, {bool isThreat = false}) async {
    final docRef = _firestore.collection('users').doc(uid);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) {
        throw Exception("User does not exist!");
      }
      
      final newTotalScans = (snapshot.data()?['totalScans'] ?? 0) + 1;
      final newThreats = isThreat 
          ? (snapshot.data()?['threatsDetected'] ?? 0) + 1 
          : (snapshot.data()?['threatsDetected'] ?? 0);
      
      transaction.update(docRef, {
        'totalScans': newTotalScans,
        'threatsDetected': newThreats,
      });
    });
  }

  // Save scan to cloud
  Future<void> saveScanToCloud(String uid, ScanRecord scan) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('scans')
        .doc(scan.id)
        .set(scan.toJson());
  }

  // Get scan history from cloud
  Future<List<ScanRecord>> getScanHistory(String uid, {int limit = 50}) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('scans')
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();
      
      return querySnapshot.docs
          .map((doc) => ScanRecord.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting scan history: $e');
      return [];
    }
  }

  // Stream scan history for real-time updates
  Stream<List<ScanRecord>> streamScanHistory(String uid, {int limit = 50}) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('scans')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ScanRecord.fromJson(doc.data()))
            .toList());
  }

  // Delete all user scans
  Future<void> clearUserHistory(String uid) async {
    final batch = _firestore.batch();
    final scans = await _firestore
        .collection('users')
        .doc(uid)
        .collection('scans')
        .get();
    
    for (var doc in scans.docs) {
      batch.delete(doc.reference);
    }
    
    await batch.commit();
  }
}

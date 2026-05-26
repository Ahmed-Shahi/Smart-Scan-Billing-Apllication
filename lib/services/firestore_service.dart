import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Save user shop data to Firestore
  static Future<String?> saveUserShopData({
    required String shopName,
    required String email,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        return 'User ID not found';
      }

      await _db.collection('users').doc(userId).set({
        'shopName': shopName,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'uid': userId,
      });

      return null; // Success
    } catch (e) {
      return 'Failed to save shop data: ${e.toString()}';
    }
  }

  /// Get user shop data from Firestore
  static Future<Map<String, dynamic>?> getUserShopData() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        return null;
      }

      final doc = await _db.collection('users').doc(userId).get();
      
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('Error fetching user data: $e');
      return null;
    }
  }

  /// Get shop name only
  static Future<String?> getShopName() async {
    try {
      final userData = await getUserShopData();
      if (userData == null) {
        return null;
      }
      final shopName = userData['shopName'];
      return shopName is String ? shopName : null;
    } catch (e) {
      print('Error getting shop name: $e');
      return null;
    }
  }

  /// Update user shop data
  static Future<String?> updateUserShopData({
    required String shopName,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        return 'User ID not found';
      }

      await _db.collection('users').doc(userId).update({
        'shopName': shopName,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return null; // Success
    } catch (e) {
      return 'Failed to update shop data: ${e.toString()}';
    }
  }
}

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class EyeScanService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  // Upload scan image to Firebase Storage and save metadata to Firestore
  Future<String> saveScanResult({
    required File imageFile,
    required String prediction,
    required double confidence,
    required String eye,
  }) async {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    try {
      // 1. Upload image to Firebase Storage
      final String fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${path.basename(imageFile.path)}';
      final Reference storageRef =
          _storage.ref().child('scan_images/$currentUserId/$fileName');

      final UploadTask uploadTask = storageRef.putFile(imageFile);
      final TaskSnapshot taskSnapshot = await uploadTask;

      // Get download URL
      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      // 2. Save scan metadata to Firestore
      final DocumentReference scanRef = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('scans')
          .add({
        'imageUrl': downloadUrl,
        'prediction': prediction,
        'confidence': confidence,
        'eye': eye,
        'timestamp': FieldValue.serverTimestamp(),
      });

      return scanRef.id;
    } catch (e) {
      print('Error saving scan result: $e');
      throw e;
    }
  }

  // Get user's scan history
  Future<List<Map<String, dynamic>>> getScanHistory() async {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('scans')
          .orderBy('timestamp', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList();
    } catch (e) {
      print('Error getting scan history: $e');
      throw e;
    }
  }
}

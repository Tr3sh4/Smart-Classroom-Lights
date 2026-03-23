import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/light.dart';

class FirebaseService {
  final _db = FirebaseFirestore.instance;

  Stream<List<Light>> getLights() {
    return _db.collection('lights').snapshots().map((snapshot) {
      debugPrint('Firestore snapshot: ${snapshot.docs.length} docs');
      return snapshot.docs.map((doc) {
        debugPrint('Doc data: ${doc.data()}');
        return Light.fromJson({...doc.data(), 'id': doc.id});
      }).toList();
    });
  }

  Future<void> addLight(Light light) async {
    await _db.collection('lights').add(light.toJson());
  }

  Future<void> updateLight(String id, Map<String, dynamic> data) async {
    await _db.collection('lights').doc(id).update(data);
  }

  Future<void> deleteLight(String id) async {
    await _db.collection('lights').doc(id).delete();
  }
}

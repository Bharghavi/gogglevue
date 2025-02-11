import 'package:firebase_core/firebase_core.dart';

import 'login_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants.dart';

class DatabaseManager {

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<bool> canOpenAdminHomePage() async {
    String? adminDb = await getAdminDatabaseId();
    if ( adminDb == null) {
      return false;
    }
    FirebaseFirestore firestore = FirebaseFirestore.instanceFor(
      app: Firebase.app(),
      databaseId: adminDb,
    );

    QuerySnapshot qs = await firestore.collection(K.adminCollection).get();

    return qs.docs.isNotEmpty;
  }

  static Future<String?> getAdminDatabaseId() async {
    String? adminId = await LoginManager.getLoggedInUserId();

    if (adminId == null) {
      return null;
    }

    QuerySnapshot querySnapshot = await _firestore
        .collection(K.adminDatabaseCollection)
        .where(K.adminId, isEqualTo: adminId)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
        String dbId = querySnapshot.docs.first[K.databaseId];
        try {
          FirebaseFirestore.instanceFor(
            app: Firebase.app(),
            databaseId: dbId,
          );
          return dbId;
        } catch (e) {
          print(e);
          return null;
        }
      } else {
      return null;
    }
  }

  static Future<bool> canCreateInstituteId(String instituteId) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection(K.adminDatabaseCollection)
        .where(K.instituteId , isEqualTo: instituteId)
        .get();

    return querySnapshot.docs.isEmpty;
  }

  static Future<void> updateInstituteId(String instituteId) async {
    String? adminId = await LoginManager.getLoggedInUserId();
    QuerySnapshot querySnapshot = await _firestore
        .collection(K.adminDatabaseCollection)
        .where(K.adminId, isEqualTo: adminId)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      String docId = querySnapshot.docs.first.id;
      await _firestore
          .collection(K.adminDatabaseCollection)
          .doc(docId)
          .update({K.instituteId: instituteId});
    }
  }
}
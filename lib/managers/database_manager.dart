import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';

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
    String? userId = await LoginManager.getLoggedInUserId();

    if (userId == null) {
      return null;
    }

    QuerySnapshot querySnapshot = await _firestore
        .collection(K.adminDatabaseCollection)
        .where(K.userId, isEqualTo: userId)
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

  static Future<void> updateInstituteIdAndAdminId(String instituteId, String adminId) async {
    String? userId = await LoginManager.getLoggedInUserId();
    QuerySnapshot querySnapshot = await _firestore
        .collection(K.adminDatabaseCollection)
        .where(K.userId, isEqualTo: userId)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      String docId = querySnapshot.docs.first.id;
      await _firestore
          .collection(K.adminDatabaseCollection)
          .doc(docId)
          .update({K.instituteId: instituteId, K.adminId: adminId});
    }
  }

  static Future<FirebaseFirestore> getAdminDatabase() async {
    String? databaseId = await getAdminDatabaseId();

    FirebaseFirestore firestore;

    if (databaseId != null) {
      try {
        firestore = FirebaseFirestore.instanceFor(
          app: Firebase.app(),
          databaseId: databaseId,
        );
      } catch (e) {
        debugPrint('could not retrieve admin db: $e');
        firestore = FirebaseFirestore.instanceFor(
          app: Firebase.app(),
          databaseId: K.defaultDB,
        );
      }
    } else {
      firestore = FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: K.defaultDB,
      );
    }
    return firestore;
  }

  static Future<String?> getLoggedInAdminId() async {
    String? userId = await LoginManager.getLoggedInUserId();

    if (userId == null) {
      return null;
    }

    QuerySnapshot querySnapshot = await _firestore
        .collection(K.adminDatabaseCollection)
        .where(K.userId, isEqualTo: userId)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first[K.adminId];
    } else {
      return null;
    }
  }
}
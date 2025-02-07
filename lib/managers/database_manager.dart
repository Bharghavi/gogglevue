import 'login_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants.dart';

class DatabaseManager {
  static Future<String?> getAdminDatabaseId() async {
    String? adminId = await LoginManager.getLoggedInUserId();

    if (adminId == null) {
      return null;
    }

    FirebaseFirestore firestore = FirebaseFirestore.instance;

    DocumentSnapshot doc = await firestore
        .collection(K.adminDatabaseCollection)
        .doc(adminId)
        .get();
    if (doc.exists) {
      return doc[K.databaseId];
    } else {
      return null;
    }
  }
}
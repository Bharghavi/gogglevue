import '/managers/database_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants.dart';

class AdminHelper {

  static Future<String> getLoggedAdminUserId() async {
    String? adminId = await DatabaseManager.getLoggedInAdminId();

    if (adminId == null) {
      throw Exception('Admin Id not found');
    }
    return adminId;
  }

  static Future<String> getLoggedInAdminName() async {
    FirebaseFirestore firestore = await DatabaseManager.getAdminDatabase();
    String? adminId = await DatabaseManager.getLoggedInAdminId();

    if (adminId == null) {
      throw Exception('Admin Id not found');
    }

    final doc = firestore.collection(K.adminCollection).doc(adminId);
    final snapshot = await doc.get();

    if (snapshot.exists) {
      return snapshot.data()?['name'];
    }
    return '';
  }
}